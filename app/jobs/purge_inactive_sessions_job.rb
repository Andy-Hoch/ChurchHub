# Deletes sessions that haven't been used for Session::INACTIVITY_LIMIT.
class PurgeInactiveSessionsJob < ApplicationJob
  queue_as :default

  def perform
    Session.inactive.in_batches.delete_all
  end
end
