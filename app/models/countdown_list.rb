class CountdownList
  attr_accessor :feed_list
  attr_accessor :upcoming_departures
  def initialize
    # grab our data from gtfs
    data = Net::HTTP.get(URI.parse("http://datamine.mta.info/mta_esi.php?key=#{ENV["api_key"]}&feed_id=31"))
    # use the gtfs-realtime-bindings gem to decode it to a feed list
    @feed_list = Transit_realtime::FeedMessage.decode(data).entity
    # empty array to use later
    @upcoming_departures = []
    self.build_countdown_models
  end

  def build_countdown_models
    @feed_list.each do |entity|
      # only do this for trips with the trip_update field... it's totally
      # optional for gtfs, so we need to make sure it has it
      if entity.field?(:trip_update)
        # get our stop time data
        train_stops = entity[:trip_update][:stop_time_update]
        # iterate over stops and find GreenPoint ave to add to our list
        train_stops.each do |stop|
          # looking just for the GreenPoint Ave (stop_id = 239) stops...
          if(stop[:stop_id].include? "G26")
            # make a new instance of our DepartureModel... So that we know
            # which direction and the arrival time is converted from POSIX
            upcoming_departure = DepartureModel.new(stop[:arrival][:time], stop[:stop_id])
            @upcoming_departures.push(upcoming_departure)
          end
        end
      end
    end
  end
end
