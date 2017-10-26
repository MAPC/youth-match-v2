require 'rails_helper'

RSpec.describe Applicant, type: :model do
  context "no direct selected applicants" do
    it "returns all chosen applicants" do
      FactoryGirl.create_list(:applicant, 5)
      FactoryGirl.create_list(:position, 2)
      expect(Applicant.chosen.count).to eq(Position.sum(:open_positions))
    end
  end

  context "some applicants direct selected jobs" do
    it "chooses number of applicants equal to un-offered positions" do
      FactoryGirl.create_list(:applicant, 5)
      FactoryGirl.create_list(:position, 2)
      FactoryGirl.create(:offer, applicant: Applicant.first, position: Position.first)
      expect(Applicant.chosen.count).to eq(Position.sum(:open_positions) - 1)
    end
  end

  context "some applicants direct selected jobs" do
    it "chooses number of applicants equal to un-accepted positions" do
      FactoryGirl.create_list(:applicant, 5)
      FactoryGirl.create_list(:position, 2)
      FactoryGirl.create(:offer, applicant: Applicant.first, position: Position.first, accepted: 'yes')
      expect(Applicant.chosen.count).to eq(Position.sum(:open_positions) - 1)
    end
  end

  context "some applicants rejected jobs" do
    it "will select applicants to fill declined jobs" do
      FactoryGirl.create_list(:applicant, 5)
      FactoryGirl.create_list(:position, 2)
      FactoryGirl.create(:offer, applicant: Applicant.first, position: Position.first, accepted: 'no_bottom_waitlist')
      expect(Applicant.chosen.count).to eq(Position.sum(:open_positions))
    end
  end

  context "some applicants expired jobs" do
    it "will select applicants to fill expired jobs" do
      FactoryGirl.create_list(:applicant, 5)
      FactoryGirl.create_list(:position, 2)
      FactoryGirl.create(:offer, applicant: Applicant.first, position: Position.first, accepted: 'expired')
      expect(Applicant.chosen.count).to eq(Position.sum(:open_positions))
    end
  end
end
