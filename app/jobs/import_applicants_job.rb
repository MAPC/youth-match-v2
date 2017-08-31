class ImportApplicantsJob < ApplicationJob
  include IcimsQueryable
  queue_as :default

  def perform(*args)
    missing_workflows.each_with_index do |workflow_id, index|
      workflow = icims_get(object: 'applicantworkflows', id: workflow_id)
      applicant_id = workflow['associatedprofile']['id']
      ImportApplicantJob.perform_in(index, applicant_id)
    end
  end

  private

  def missing_workflows
    local_workflows = Applicant.all.pluck(:workflow_id)
    remote_workflows = []
    current_count = 1000
    while current_count == 1000
      response = icims_search(type: 'applicantworkflows',
                              body: %Q{{"filters":[{"name":"applicantworkflow.status","value":["D10100","C12295","D10105","C22001","C12296"],"operator":"="},{"name":"applicantworkflow.job.id","value":["12634"],"operator":"="},{"name":"applicantworkflow.id","value":["#{remote_workflows.last}"],"operator":">"}],"operator":"&"}})
      Rails.logger.info response.inspect
      remote_workflows.push(*response['searchResults'].pluck('id'))
      current_count = response['searchResults'].pluck('id').count
    end
    remote_workflows - local_workflows
  end
end
