class PositionSerializer < ActiveModel::Serializer
  attributes :id, :latitude, :longitude, :category, :site_name, :title, :duties_responsbilities,
    :ideal_candidate,
    :open_positions,
    :external_application_url,
    :external_application_url,
    :primary_contact_person,
    :primary_contact_person_title,
    :primary_contact_person_phone,
    :site_phone,
    :address,
    :neighborhood,
    :primary_contact_person_email

  def latitude
    object.location.try(:y)
  end

  def longitude
    object.location.try(:x)
  end

  has_many :applicants, serializer: ApplicantSerializer do
    link(:relationships) { position_applicants_path(position_id: object.id) }
    applicants = object.applicants
    # The following code is needed to avoid n+1 queries.
    # Core devs are working to remove this necessity.
    # See: https://github.com/rails-api/active_model_serializers/issues/1325
    applicants.loaded? ? applicants : applicants.none
  end

  has_many :requisitions, serializer: RequisitionSerializer do
    link(:relationships) { position_requisitions_path(position_id: object.id) }
    requisitions = object.requisitions
    # The following code is needed to avoid n+1 queries.
    # Core devs are working to remove this necessity.
    # See: https://github.com/rails-api/active_model_serializers/issues/1325
    requisitions.loaded? ? requisitions.none : requisitions
  end

  has_many :picks, serializer: PickSerializer do
    link(:relationships) { position_picks_path(position_id: object.id) }
    picks = object.picks
    # The following code is needed to avoid n+1 queries.
    # Core devs are working to remove this necessity.
    # See: https://github.com/rails-api/active_model_serializers/issues/1325
    picks.loaded? ? picks.none : picks
  end

  has_many :selections, serializer: ApplicantSerializer do
    link(:relationships) { position_applicants_path(position_id: object.id) }
    selections = object.selections
    # The following code is needed to avoid n+1 queries.
    # Core devs are working to remove this necessity.
    # See: https://github.com/rails-api/active_model_serializers/issues/1325
    selections.loaded? ? selections : selections.none
  end
end
