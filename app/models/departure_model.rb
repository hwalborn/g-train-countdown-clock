class DepartureModel
  def initialize(arrival, direction)
    # GTFS gives time in POSIX, gotta make it this time
    @arrival = Time.at(arrival)
    if direction.include? "N"
      @direction = 'NorthBound'
    else
      @direction = 'SouthBound'
    end
  end
end
