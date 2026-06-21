class UploadedFilesController < ApplicationController
  before_action :require_login, except: [ :show ]

  def index
    @new_file = UploadedFile.new(
      expires_at: default_expires_at,
      share_type: :private
    )
    @uploaded_files = UploadedFile.all
  end

  def show
  end

  def create
    attributes = uploaded_file_params
    @uploaded_file = UploadedFile.new(
      expires_at: expires_at_param(attributes[:expires_at]),
      share_type: share_type_param(attributes[:share_type])
    )

    if attributes[:file].blank?
      redirect_to uploaded_files_path, alert: t(".missing_file")
      return
    end

    @uploaded_file.file.attach(attributes[:file])
    blob = @uploaded_file.file.blob

    @uploaded_file.assign_attributes(
      filename: blob.filename.to_s,
      content_type: blob.content_type.presence || "application/octet-stream",
      file_size: blob.byte_size
    )

    if @uploaded_file.save
      redirect_to uploaded_files_path, notice: t(".created")
    else
      redirect_to uploaded_files_path, alert: @uploaded_file.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def uploaded_file_params
    params.require(:uploaded_file).permit(:file, :share_type, :expires_at)
  end

  def share_type_param(value)
    share_type = value.to_s
    UploadedFile.share_types.key?(share_type) ? share_type : "private"
  end

  def expires_at_param(value)
    Date.strptime(value.to_s, "%d/%m/%Y").in_time_zone.end_of_day
  rescue Date::Error
    default_expires_at
  end

  def default_expires_at
    2.days.from_now.end_of_day
  end
end
