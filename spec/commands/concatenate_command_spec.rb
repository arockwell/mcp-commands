require 'rails_helper'
require 'fakefs/spec_helpers'

RSpec.describe ConcatenateCommand do
  include FakeFS::SpecHelpers

  let(:test_dir) { '/test_files' }
  let(:file1_path) { "#{test_dir}/source1.txt" }
  let(:file2_path) { "#{test_dir}/source2.txt" }
  let(:output_path) { "#{test_dir}/combined.txt" }

  before do
    FileUtils.mkdir_p(test_dir)
    File.write(file1_path, "Content from file 1\n")
    File.write(file2_path, "Content from file 2\n")
  end

  describe '#execute' do
    context 'when files exist' do
      it 'successfully concatenates files' do
        command = described_class.new(
          files: [ file1_path, file2_path ],
          output_path: output_path
        )

        result = command.execute

        expect(result[:success]).to be true
        expect(File.read(output_path)).to eq("Content from file 1\nContent from file 2\n")
      end

      it 'preserves file order' do
        command = described_class.new(
          files: [ file2_path, file1_path ],
          output_path: output_path
        )

        result = command.execute

        expect(result[:success]).to be true
        expect(File.read(output_path)).to eq("Content from file 2\nContent from file 1\n")
      end

      it 'creates output directory if it does not exist' do
        new_output_path = "#{test_dir}/new_dir/combined.txt"
        command = described_class.new(
          files: [ file1_path ],
          output_path: new_output_path
        )

        result = command.execute

        expect(result[:success]).to be true
        expect(File.exist?(new_output_path)).to be true
      end
    end

    context 'when input file does not exist' do
      it 'returns an error' do
        command = described_class.new(
          files: [ '/nonexistent.txt' ],
          output_path: output_path
        )

        result = command.execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('No such file or directory')
      end

      it 'returns error when some files exist but others do not' do
        command = described_class.new(
          files: [ file1_path, '/nonexistent.txt' ],
          output_path: output_path
        )

        result = command.execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('No such file or directory')
      end
    end

    context 'when output directory does not exist and cannot be created' do
      it 'returns an error' do
        # Create a file where we want to create a directory
        File.write("#{test_dir}/blocked_dir", "blocking file")

        command = described_class.new(
          files: [ file1_path ],
          output_path: "#{test_dir}/blocked_dir/output.txt"
        )

        result = command.execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('No such file or directory')
      end
    end
  end
end
