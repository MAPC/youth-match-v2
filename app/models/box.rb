class Box < ApplicationRecord
  def self.intersects(latlong)
    raise 'please provide a location' if latlong.blank?
    if latlong.is_a? String
      raise 'please format as lat,long' if latlong.exclude?(',')
      latlong = latlong.strip.split(',')
      location = RGeo::Geographic.spherical_factory(srid: 4326)
                                 .point(latlong[1], latlong[0])
    else
      location = latlong[:location]
    end
    # Why doesn't #{location} work here and I have to use point: location?
    where('ST_Intersects(geom, :point)', point: location).first
  end
end
