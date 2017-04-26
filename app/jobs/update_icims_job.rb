class UpdateIcimsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    AssociateRecruitingWorkflowJob.perform_now
    UpdateRejectedApplicantsJob.perform_now
  end
end
