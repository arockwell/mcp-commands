require 'rails_helper'
require 'fakefs/safe'

RSpec.describe McpController, type: :request do
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

  describe 'POST #concatenate' do
    context 'with valid parameters' do
      it 'successfully concatenates files' do
        post mcp_concatenate_path, params: {
          files: [ file1_path, file2_path ],
          output_path: output_path
        }, as: :json

        expect(response).to have_http_status(:success)
        expect(File.read(output_path)).to eq("Content from file 1\nContent from file 2\n")
      end

      it 'preserves file order' do
        post mcp_concatenate_path, params: {
          files: [ file2_path, file1_path ],
          output_path: output_path
        }, as: :json

        expect(response).to have_http_status(:success)
        expect(File.read(output_path)).to eq("Content from file 2\nContent from file 1\n")
      end

      it 'creates output directory if it does not exist' do
        new_output_path = "#{test_dir}/new_dir/combined.txt"

        post mcp_concatenate_path, params: {
          files: [ file1_path ],
          output_path: new_output_path
        }, as: :json

        expect(response).to have_http_status(:success)
        expect(File.exist?(new_output_path)).to be true
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
      it 'returns an error' do
        post mcp_concatenate_path, params: {
          files: [ '/nonexistent.txt' ],
          output_path: output_path
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['success']).to be false
        expect(JSON.parse(response.body)['error']).to include('No such file or directory')
      end

      it 'returns error when some files exist but others do not' do
        post mcp_concatenate_path, params: {
          files: [ file1_path, '/nonexistent.txt' ],
          output_path: output_path
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['success']).to be false
      end
    end
  end
end
