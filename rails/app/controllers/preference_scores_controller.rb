class PreferenceScoresController < ApplicationController
  def create
    BuildPreferenceListsJob.perform_later
    render body: 'Travel time scores will be assigned for all applicants.'
  end
end
