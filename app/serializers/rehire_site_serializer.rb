class RehireSiteSerializer < ActiveModel::Serializer
  attributes :id, :site_name, :person_name, :should_rehire
end
