class PickSerializer < ActiveModel::Serializer
  attributes :id, :status

  has_one :applicant, serializer: ApplicantSerializer do
    # link(:relationships) { applicant_path(id: object.applicant.id) }
    applicant = object.applicant
    # The following code is needed to avoid n+1 queries.
    # Core devs are working to remove this necessity.
    # See: https://github.com/rails-api/active_model_serializers/issues/1325
    applicant.nil? ? applicant.none : applicant
  end

  has_one :position, serializer: PositionSerializer do
    # link(:relationships) { position_path(id: object.position.id) }
    position = object.position
    # The following code is needed to avoid n+1 queries.
    # Core devs are working to remove this necessity.
    # See: https://github.com/rails-api/active_model_serializers/issues/1325
    position.nil? ? position.none : position
  end
end
