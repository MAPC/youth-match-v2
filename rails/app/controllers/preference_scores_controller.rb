class PreferenceScoresController < ApplicationController
  def create
    BuildPreferenceListsJob.perform_later
    render body: 'Preference scores will be assigned for all applicants.'
  end
end
