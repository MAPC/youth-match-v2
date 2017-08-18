require 'rails_helper'

RSpec.describe "outgoing_messages/edit", type: :view do
  before(:each) do
    @outgoing_message = assign(:outgoing_message, OutgoingMessage.create!(
      :to => "",
      :body => "MyString"
    ))
  end

  it "renders the edit outgoing_message form" do
    render

    assert_select "form[action=?][method=?]", outgoing_message_path(@outgoing_message), "post" do

      assert_select "input#outgoing_message_to[name=?]", "outgoing_message[to]"

      assert_select "input#outgoing_message_body[name=?]", "outgoing_message[body]"
    end
  end
end
