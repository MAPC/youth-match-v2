require 'rails_helper'

RSpec.describe "outgoing_messages/new", type: :view do
  before(:each) do
    assign(:outgoing_message, OutgoingMessage.new(
      :to => "",
      :body => "MyString"
    ))
  end

  it "renders new outgoing_message form" do
    render

    assert_select "form[action=?][method=?]", outgoing_messages_path, "post" do

      assert_select "input#outgoing_message_to[name=?]", "outgoing_message[to]"

      assert_select "input#outgoing_message_body[name=?]", "outgoing_message[body]"
    end
  end
end
