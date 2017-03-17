class OfferSerializer < ActiveModel::Serializer
  attributes :id, :applicant, :position, :accepted
end
