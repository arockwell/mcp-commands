class McpController < ApplicationController
  def concatenate
    return render_bad_request if missing_required_params?

    command = ConcatenateCommand.new(files: params[:files], output_path: params[:output_path])
    result = command.execute

    return render_success(result) if result[:success]
    render_error(result)
  end

  private

  def missing_required_params?
    params[:files].blank? || params[:output_path].blank?
  end

  def render_bad_request
    render json: { success: false, error: "Files and output_path are required" },
           status: :bad_request
  end

  def render_success(result)
    render json: result
  end

  def render_error(result)
    render json: result, status: :unprocessable_entity
  end
end
