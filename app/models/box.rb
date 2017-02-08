class Box < ApplicationRecord
  def self.intersects(latlong)
    raise Error.new('please format as lat,long') if latlong.excludes?(',') || latlong.blank?
    latlong = latlong.split(",")
    location = RGeo::Geographic.spherical_factory(srid: 4326)
                               .point(latlong[1], latlong[0])
    # Why doesn't #{location} work here and I have to use point: location?
    where('ST_Intersects(geom, :point)', point: location).first
  end
end
