class PreferenceScoresController < ApplicationController
  def create
    BuildPreferenceListsJob.perform_later
  end
end
