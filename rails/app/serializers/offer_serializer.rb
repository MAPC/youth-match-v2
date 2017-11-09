class OfferSerializer < ActiveModel::Serializer
  attributes :id, :accepted, :exported

  has_one :applicant, seralizer: ApplicantSerializer do
    applicant = object.applicant

    applicant.nil? ? applicant.none : applicant
  end

  has_one :position, serializer: PositionSerializer do
    position = object.position

    position.nil? ? position.none : position
  end

end
