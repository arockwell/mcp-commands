class ConcatenateCommand
  def initialize(files:, output_path:)
    @files = files
    @output_path = output_path
  end

  def execute
    File.open(@output_path, "w") do |output_file|
      @files.each do |file_path|
        File.open(file_path, "r") do |input_file|
          output_file.write(input_file.read)
        end
      end
    end
    { success: true, output_path: @output_path }
  rescue StandardError => e
    { success: false, error: e.message }
  end
end
