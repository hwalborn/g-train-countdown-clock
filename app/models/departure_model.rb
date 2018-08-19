class DepartureModel
  attr_accessor :arrival
  def initialize(arrival, direction)
    # GTFS gives time in POSIX, gotta make it this time
    arrival_time = Time.at(arrival)
    # find the difference between arrival time and current Time
    # then divide by 60 to find how many minutes until arrival
    @arrival = (arrival_time - Time.now) / 60

    # Gotta know if we are going to court square or church ave
    if direction.include? "N"
      @direction = 'NorthBound'
    else
      @direction = 'SouthBound'
    end
  end
end
