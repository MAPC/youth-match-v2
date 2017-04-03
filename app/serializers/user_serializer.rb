class UserSerializer < ActiveModel::Serializer
  attributes :id, :applicant_interests

  def applicant_interests
    object.applicant.nil? ? nil : object.applicant.interests
  end

  has_one :applicant, serializer: ApplicantSerializer do
    # link(:relationships) { applicant_path(id: object.applicant.id) }
    applicant = object.applicant
    # The following code is needed to avoid n+1 queries.
    # Core devs are working to remove this necessity.
    # See: https://github.com/rails-api/active_model_serializers/issues/1325
    applicant.nil? ? nil : applicant
  end

  has_many :positions, serializer: PositionSerializer do
    # link(:relationships) { position_path(id: object.id) }

    positions = object.positions
    # The following code is needed to avoid n+1 queries.
    # Core devs are working to remove this necessity.
    # See: https://github.com/rails-api/active_model_serializers/issues/1325
    positions.loaded? ? nil : positions
  end


end
