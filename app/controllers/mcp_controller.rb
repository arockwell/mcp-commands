class McpController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :ensure_json_request

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

  def ensure_json_request
    return if request.format.json?
    render json: { error: "Only JSON requests are allowed" }, status: :not_acceptable
  end
end
