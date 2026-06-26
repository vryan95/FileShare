class FileCleanupJob < ApplicationJob
  queue_as :urgent

  def perform(*args)
    files_to_delete = UploadedFile.where("expires_at < ?", Date.current)
    files_to_delete.destroy_all
  end
end
