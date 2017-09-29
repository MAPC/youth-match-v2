require 'rails_helper'

RSpec.describe "outgoing_messages/show", type: :view do
  before(:each) do
    @outgoing_message = assign(:outgoing_message, OutgoingMessage.create!(
      :to => "",
      :body => "Body"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Body/)
  end
end
