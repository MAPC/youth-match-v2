class OutgoingMessageSerializer < ActiveModel::Serializer
  attributes :id, :to, :body
end
