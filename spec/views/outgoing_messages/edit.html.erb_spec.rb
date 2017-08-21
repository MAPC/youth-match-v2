require 'rails_helper'

RSpec.describe "outgoing_messages/edit", type: :view do
  before(:each) do
    user = FactoryGirl.create(:user)
    sign_in user
    @outgoing_message = assign(:outgoing_message, OutgoingMessage.create!(
      :to => "860-883-8042",
      :body => "MyString"
    ))
  end

  it "renders the edit outgoing_message form" do
    render
    expect(rendered).to have_selector "textarea[name='outgoing_message[to][]']"
    expect(rendered).to have_selector "input[name='outgoing_message[body]']"
  end
end
