require 'rails_helper'

RSpec.describe "outgoing_messages/index", type: :view do
  before(:each) do
    user = FactoryGirl.create(:user)
    sign_in user
    assign(:outgoing_messages, [
      OutgoingMessage.create!(
        :to => ["1231231234"],
        :body => "Body"
      ),
      OutgoingMessage.create!(
        :to => ["9879879876"],
        :body => "Body"
      )
    ])
  end

  it "renders a list of outgoing_messages" do
    render
    expect(rendered).to match(/1231231234/)
    expect(rendered).to match(/9879879876/)
    expect(rendered).to match(/Body/)
  end
end
