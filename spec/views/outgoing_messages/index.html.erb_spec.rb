require 'rails_helper'

RSpec.describe "outgoing_messages/index", type: :view do
  before(:each) do
    assign(:outgoing_messages, [
      OutgoingMessage.create!(
        :to => "",
        :body => "Body"
      ),
      OutgoingMessage.create!(
        :to => "",
        :body => "Body"
      )
    ])
  end

  it "renders a list of outgoing_messages" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Body".to_s, :count => 2
  end
end
