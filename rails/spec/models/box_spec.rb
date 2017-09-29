require 'rails_helper'

RSpec.describe Box, type: :model do
  it 'should return the first intersecting box' do
    pending "No need to test that PostGIS works but we can if we want later"
    box = create(:box)
    # Create a point at MAPC. x = longitude and y = latitude
    expect(Box.intersects('-71.061315, 42.355059').g250m_id).to eq(148221)
  end
end
