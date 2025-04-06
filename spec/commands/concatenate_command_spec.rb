require 'rails_helper'

RSpec.describe ConcatenateCommand do
  let(:file1_path) { './tmp/test/file1.txt' }
  let(:file2_path) { './tmp/test/file2.txt' }
  let(:output_path) { './tmp/test/output.txt' }
  let(:file1_content) { "Content from file 1\n" }
  let(:file2_content) { "Content from file 2\n" }

  describe '#execute' do
    context 'when files exist' do
      before do
        allow(File).to receive(:open).with(file1_path, 'r').and_yield(StringIO.new(file1_content))
        allow(File).to receive(:open).with(file2_path, 'r').and_yield(StringIO.new(file2_content))
        allow(File).to receive(:open).with(output_path, 'w').and_yield(StringIO.new)
        allow(FileUtils).to receive(:mkdir_p)
      end

      it 'successfully concatenates files' do
        output = StringIO.new
        allow(File).to receive(:open).with(output_path, 'w').and_yield(output)

        command = described_class.new(
          files: [ file1_path, file2_path ],
          output_path: output_path
        )

        result = command.execute

        expect(result[:success]).to be true
        expect(output.string).to eq(file1_content + file2_content)
      end

      it 'preserves file order' do
        output = StringIO.new
        allow(File).to receive(:open).with(output_path, 'w').and_yield(output)

        command = described_class.new(
          files: [ file2_path, file1_path ],
          output_path: output_path
        )

        result = command.execute

        expect(result[:success]).to be true
        expect(output.string).to eq(file2_content + file1_content)
      end

      it 'creates output directory if it does not exist' do
        new_output_path = './tmp/test/new_dir/output.txt'
        output = StringIO.new
        allow(File).to receive(:open).with(new_output_path, 'w').and_yield(output)

        command = described_class.new(
          files: [ file1_path ],
          output_path: new_output_path
        )

        result = command.execute

        expect(result[:success]).to be true
        expect(FileUtils).to have_received(:mkdir_p).with('./tmp/test/new_dir')
      end
    end

    context 'when input file does not exist' do
      before do
        allow(FileUtils).to receive(:mkdir_p)
        allow(File).to receive(:open).with(output_path, 'w').and_yield(StringIO.new)
      end

      it 'returns an error' do
        allow(File).to receive(:open).with('./tmp/test/nonexistent.txt', 'r')
          .and_raise(Errno::ENOENT.new("No such file or directory - ./tmp/test/nonexistent.txt"))

        command = described_class.new(
          files: [ './tmp/test/nonexistent.txt' ],
          output_path: output_path
        )

        result = command.execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('No such file or directory')
      end

      it 'returns error when some files exist but others do not' do
        allow(File).to receive(:open).with(file1_path, 'r').and_yield(StringIO.new(file1_content))
        allow(File).to receive(:open).with('./tmp/test/nonexistent.txt', 'r')
          .and_raise(Errno::ENOENT.new("No such file or directory - ./tmp/test/nonexistent.txt"))

        command = described_class.new(
          files: [ file1_path, './tmp/test/nonexistent.txt' ],
          output_path: output_path
        )

        result = command.execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('No such file or directory')
      end
    end

    context 'when output directory cannot be created' do
      before do
        allow(FileUtils).to receive(:mkdir_p)
          .with('./tmp/test/blocked_dir')
          .and_raise(Errno::EACCES.new("Permission denied - ./tmp/test/blocked_dir"))
      end

      it 'returns an error' do
        command = described_class.new(
          files: [ file1_path ],
          output_path: './tmp/test/blocked_dir/output.txt'
        )

        result = command.execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('Permission denied')
      end
    end
  end
end
