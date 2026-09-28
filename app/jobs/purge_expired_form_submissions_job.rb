# Deletes submissions older than the retention period set on each form.
class PurgeExpiredFormSubmissionsJob < ApplicationJob
  queue_as :default

  def perform
    Form.where.not(retention_months: nil).find_each do |form|
      form.expired_submissions.delete_all
    end
  end
end
