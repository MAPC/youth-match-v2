require 'rails_helper'

RSpec.describe ImportPositionsJob, :vcr, type: :job do
  it 'should import positions' do
    ImportPositionsJob.perform_now
    expect(Position.all.count).to be > 0
  end
end
