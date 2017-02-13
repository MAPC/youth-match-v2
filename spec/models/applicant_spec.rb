require 'rails_helper'

RSpec.describe Applicant, type: :model do
  it 'assigns random lottery numbers to all the applicants' do
    applicants = create_list(:applicant, 25)
    Applicant.assign_lottery_numbers

    expect(applicants.first.lottery_number).not_to eq(1)
  end
end
