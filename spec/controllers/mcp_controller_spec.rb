require 'rails_helper'

RSpec.describe McpController, type: :request do
  let(:file1_path) { './tmp/test/file1.txt' }
  let(:file2_path) { './tmp/test/file2.txt' }
  let(:output_path) { './tmp/test/output.txt' }
  let(:file1_content) { "Content from file 1\n" }
  let(:file2_content) { "Content from file 2\n" }

  describe 'POST #concatenate' do
    context 'with valid parameters' do
      before do
        allow(File).to receive(:open).with(file1_path, 'r').and_yield(StringIO.new(file1_content))
        allow(File).to receive(:open).with(file2_path, 'r').and_yield(StringIO.new(file2_content))
        allow(File).to receive(:open).with(output_path, 'w').and_yield(StringIO.new)
        allow(FileUtils).to receive(:mkdir_p)
      end

      it 'successfully concatenates files' do
        output = StringIO.new
        allow(File).to receive(:open).with(output_path, 'w').and_yield(output)

        post mcp_concatenate_path, params: {
          files: [ file1_path, file2_path ],
          output_path: output_path
        }, as: :json

        expect(response).to have_http_status(:success)
        expect(output.string).to eq(file1_content + file2_content)
      end

      it 'preserves file order' do
        output = StringIO.new
        allow(File).to receive(:open).with(output_path, 'w').and_yield(output)

        post mcp_concatenate_path, params: {
          files: [ file2_path, file1_path ],
          output_path: output_path
        }, as: :json

        expect(response).to have_http_status(:success)
        expect(output.string).to eq(file2_content + file1_content)
      end

      it 'creates output directory if it does not exist' do
        new_output_path = './tmp/test/new_dir/output.txt'
        output = StringIO.new
        allow(File).to receive(:open).with(new_output_path, 'w').and_yield(output)

        post mcp_concatenate_path, params: {
          files: [ file1_path ],
          output_path: new_output_path
        }, as: :json

        expect(response).to have_http_status(:success)
        expect(FileUtils).to have_received(:mkdir_p).with('./tmp/test/new_dir')
      end
    end

    context 'with missing parameters' do
      it 'returns bad request when files parameter is missing' do
        post mcp_concatenate_path, params: {
          output_path: output_path
        }, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('Files and output_path are required')
      end

      it 'returns bad request when output_path parameter is missing' do
        post mcp_concatenate_path, params: {
          files: [ file1_path ]
        }, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('Files and output_path are required')
      end

      it 'returns bad request when files array is empty' do
        post mcp_concatenate_path, params: {
          files: [],
          output_path: output_path
        }, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('Files and output_path are required')
      end
    end

    context 'when file does not exist' do
      before do
        allow(FileUtils).to receive(:mkdir_p)
        allow(File).to receive(:open).with(output_path, 'w').and_yield(StringIO.new)
      end

      it 'returns an error' do
        allow(File).to receive(:open).with('./tmp/test/nonexistent.txt', 'r')
          .and_raise(Errno::ENOENT.new("No such file or directory - ./tmp/test/nonexistent.txt"))

        post mcp_concatenate_path, params: {
          files: [ './tmp/test/nonexistent.txt' ],
          output_path: output_path
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['success']).to be false
        expect(JSON.parse(response.body)['error']).to include('No such file or directory')
      end

      it 'returns error when some files exist but others do not' do
        allow(File).to receive(:open).with(file1_path, 'r').and_yield(StringIO.new(file1_content))
        allow(File).to receive(:open).with('./tmp/test/nonexistent.txt', 'r')
          .and_raise(Errno::ENOENT.new("No such file or directory - ./tmp/test/nonexistent.txt"))

        post mcp_concatenate_path, params: {
          files: [ file1_path, './tmp/test/nonexistent.txt' ],
          output_path: output_path
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['success']).to be false
        expect(JSON.parse(response.body)['error']).to include('No such file or directory')
      end
    end
  end
end
