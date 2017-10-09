require 'rails_helper'

RSpec.describe "outgoing_messages/new", type: :view do
  before(:each) do
    user = FactoryGirl.create(:user)
    sign_in user
    assign(:outgoing_message, OutgoingMessage.new(
      :to => "",
      :body => "MyString"
    ))
  end

  it "renders new outgoing_message form" do
    render
    expect(rendered).to have_selector "input[name='outgoing_message[body]']"
  end
end
