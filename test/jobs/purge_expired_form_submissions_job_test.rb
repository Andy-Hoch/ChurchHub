require "test_helper"

class PurgeExpiredFormSubmissionsJobTest < ActiveJob::TestCase
  test "deletes submissions older than the retention period" do
    forms(:prayer).update!(retention_months: 3)
    form_submissions(:read).update_column(:created_at, 4.months.ago)
    form_submissions(:other).update_column(:created_at, 4.months.ago)

    PurgeExpiredFormSubmissionsJob.perform_now

    assert_not FormSubmission.exists?(form_submissions(:read).id)
    assert FormSubmission.exists?(form_submissions(:unread).id)
    assert FormSubmission.exists?(form_submissions(:other).id), "Formulare ohne Frist bleiben unberührt"
  end
end
