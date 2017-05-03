namespace :lottery do
  desc 'Build the preference lists'
  task build_preference_lists: :environment do
    start_time = Time.now
    BuildPreferenceListsJob.perform_now
    puts "Time to run in seconds: #{Time.now - start_time}"
  end

  desc 'Assign lottery numbers'
  task assign_lottery_numbers: :environment do
    Applicant.order("RANDOM()").each_with_index do |applicant, index|
      applicant.lottery_number = index
      applicant.save!
    end
  end

  desc 'Match the applicants to their jobs'
  task match: :environment do
    match_applicants_to_positions
  end

  desc 'Print match results'
  task print: :environment do
    Applicant.chosen(1).each do |applicant|
      preference = Preference.find_by(applicant: applicant, position: applicant.offer.position)
      puts "Applicant: #{applicant.email}, Position: #{applicant.offer.position.id} #{applicant.offer.position.title}, Score: #{preference.score}, Travel Time Score: #{preference.travel_time_score}"
    end
  end

  private

  def travel_time_score(applicant, position)
    minutes = travel_time(applicant, position) / 60
    applicant.prefers_nearby? ? care(minutes) : dont_care(minutes)
  end

  def travel_time(applicant, position)
    return TravelTime.find_by(
      input_id:     applicant.grid_id,
      target_id:    position.grid_id,
      travel_mode:  applicant.has_transit_pass ? "transit" : "walking"
    ).time
  rescue NoMethodError
    40.minutes.to_i
  end

  def care(minutes)
    minutes < 30 ? (0.008 * (minutes ** 2)) - (0.5833 * minutes) + 5 : -5
  end

  def dont_care(minutes)
    minutes < 40 ? (-0.25 * minutes) + 5 : -5
  end

  def interest_score(applicant, position)
    magnitude = applicant.prefers_interest? ? 5 : 3
    matches = (applicant.interests & [position.category]).any? ? 1 : -1
    return magnitude * matches
  end

  def match_applicants_to_positions
    Applicant.chosen.each do |applicant|
      applicant.match_to_position
    end
    if Position.joins("LEFT OUTER JOIN offers ON offers.position_id = positions.id").where("offers.id IS null").any?
      match_applicants_to_positions
    end
  end
end
