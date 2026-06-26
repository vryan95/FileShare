require "test_helper"

class FileCleanupJobTest < ActiveJob::TestCase
  test "destroys uploaded files that expired before today" do
    expired_file = uploaded_files(:one)
    current_file = uploaded_files(:two)

    expired_file.update_column(:expires_at, 1.day.ago)
    current_file.update_column(:expires_at, Date.current)

    assert_difference -> { UploadedFile.count }, -1 do
      FileCleanupJob.perform_now
    end

    assert_raises(ActiveRecord::RecordNotFound) { expired_file.reload }
    assert_nothing_raised { current_file.reload }
  end
end
