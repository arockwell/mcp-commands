require "test_helper"

class McpControllerTest < ActionDispatch::IntegrationTest
  def setup
    @temp_dir = Dir.mktmpdir
    @file1_path = File.join(@temp_dir, "file1.txt")
    @file2_path = File.join(@temp_dir, "file2.txt")
    @output_path = File.join(@temp_dir, "output.txt")

    File.write(@file1_path, "Content from file 1\n")
    File.write(@file2_path, "Content from file 2\n")
  end

  def teardown
    FileUtils.remove_entry(@temp_dir)
  end

  test "successfully concatenates files" do
    post mcp_concatenate_path, params: {
      files: [ @file1_path, @file2_path ],
      output_path: @output_path
    }, as: :json

    assert_response :success
    assert_equal "Content from file 1\nContent from file 2\n", File.read(@output_path)
  end

  test "returns bad request when files parameter is missing" do
    post mcp_concatenate_path, params: {
      output_path: @output_path
    }, as: :json

    assert_response :bad_request
    assert_equal "Files and output_path are required", JSON.parse(response.body)["error"]
  end

  test "returns bad request when output_path parameter is missing" do
    post mcp_concatenate_path, params: {
      files: [ @file1_path ]
    }, as: :json

    assert_response :bad_request
    assert_equal "Files and output_path are required", JSON.parse(response.body)["error"]
  end

  test "returns error when file doesn't exist" do
    post mcp_concatenate_path, params: {
      files: [ "nonexistent.txt" ],
      output_path: @output_path
    }, as: :json

    assert_response :unprocessable_entity
    assert_not JSON.parse(response.body)["success"]
    assert_includes JSON.parse(response.body)["error"], "No such file or directory"
  end
end
