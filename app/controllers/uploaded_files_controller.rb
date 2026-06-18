class UploadedFilesController < ApplicationController
  before_action :require_login, except: [ :show ]

  def index
    @new_file = UploadedFile.new
    @uploaded_files = UploadedFile.all
  end

  def show
  end

  def create
    @uploaded_file = UploadedFile.new(
      expires_at: 30.days.from_now,
      share_type: :private
    )

    if uploaded_file_params[:file].blank?
      redirect_to uploaded_files_path, alert: t(".missing_file")
      return
    end

    @uploaded_file.file.attach(uploaded_file_params[:file])
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
    params.require(:uploaded_file).permit(:file)
  end
end
