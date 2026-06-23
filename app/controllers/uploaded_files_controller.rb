class UploadedFilesController < ApplicationController
  before_action :require_login, except: [ :show ]

  def index
    @new_file = UploadedFile.new(
      expires_at: default_expires_at,
      share_type: :private,
      user: current_user
    )
    @uploaded_files = current_user.uploaded_files.order(created_at: :desc)
    @shared_files = UploadedFile.share_type_public.or(UploadedFile.share_type_internal).order(created_at: :desc)
  end

  def show
    @uploaded_file = UploadedFile.includes(file_attachment: :blob).find_by!(upload_uuid: params[:upload_uuid])

    return if can_view_uploaded_file?(@uploaded_file)

    if logged_in?
      redirect_to uploaded_files_path, alert: t(".not_authorized")
    else
      redirect_to login_path, alert: t(".login_required")
    end
  end

  def create
    attributes = uploaded_file_params
    @uploaded_file = UploadedFile.new(
      expires_at: expires_at_param(attributes[:expires_at]),
      share_type: share_type_param(attributes[:share_type]),
      user: current_user
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

  def update
    @uploaded_file = current_user.uploaded_files.find_by!(upload_uuid: params[:upload_uuid])
    attributes = uploaded_file_params

    @uploaded_file.assign_attributes(
      share_type: share_type_param(attributes[:share_type], fallback: @uploaded_file.share_type),
      expires_at: expires_at_param(attributes[:expires_at], fallback: @uploaded_file.expires_at)
    )

    if @uploaded_file.save
      redirect_to uploaded_files_path, notice: t(".updated")
    else
      redirect_to uploaded_files_path, alert: @uploaded_file.errors.full_messages.to_sentence
    end
  end

  def destroy
    @uploaded_file = current_user.uploaded_files.find_by!(upload_uuid: params[:upload_uuid])

    if @uploaded_file.destroy
      redirect_to uploaded_files_path, notice: t(".destroyed")
    else
      redirect_to uploaded_files_path, alert: @uploaded_file.errors.full_messages.to_sentence
    end
  end

  private

  def uploaded_file_params
    params.require(:uploaded_file).permit(:file, :share_type, :expires_at)
  end

  def share_type_param(value, fallback: "private")
    share_type = value.to_s
    UploadedFile.share_types.key?(share_type) ? share_type : fallback
  end

  def expires_at_param(value, fallback: default_expires_at)
    Date.strptime(value.to_s, "%d/%m/%Y").in_time_zone.end_of_day
  rescue Date::Error
    fallback
  end

  def default_expires_at
    2.days.from_now.end_of_day
  end

  def can_view_uploaded_file?(uploaded_file)
    return true if uploaded_file.share_type_public?
    return false unless logged_in?

    uploaded_file.share_type_internal? || uploaded_file.user_id == current_user.id
  end
end
