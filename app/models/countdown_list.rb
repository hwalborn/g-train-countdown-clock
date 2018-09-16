class CountdownList
  attr_accessor :upcoming_departures,
                :feed_list
  def initialize
    # grab our data from gtfs, feed_id = 31 is the G train
    data = Net::HTTP
           .get(URI
           .parse("http://datamine.mta.info/mta_esi.php?key=#{ENV["api_key"]}&feed_id=31"))
    # use the gtfs-realtime-bindings gem to decode it to a feed list
    @feed_list = Transit_realtime::FeedMessage.decode(data).entity
    # make a hash with empty arrays to keep track of our departures
    @upcoming_departures = {
      departure_list_north: [],
      departure_list_south: []
    }
    # make it all happen
    self.build_departure_lists
  end

  def build_departure_lists
    @feed_list.each do |entity|
      # only do this for trips with the trip_update field... it's totally
      # optional for gtfs, so we need to make sure it has it
      if entity.field?(:trip_update)
        # get our stop time data
        departures = entity[:trip_update][:stop_time_update]
        .select do |stop|
          # looking just for the GreenPoint Ave (stop_id = G26) stops...
          stop[:stop_id].include? "G26"
        end
        .map do |stop|
          # get the arrival time from the gtfs data
          arrival_time = stop[:arrival][:time]
          # convert current time to POSIX and then subtract it from
          # the arrival time so we know how many seconds until the
          # arrival of the train. Then divide by 60 to get minutes
          countdown_time = (arrival_time - Time.now.to_f) / 60

          # we don't care about times that have passed or
          # times that are more than 15 minutes away
          if(countdown_time > 0 && countdown_time <= 45)
            # insert into sorted array depending on which direction
            # this train is traveling
            if stop[:stop_id].include? 'N'
              @upcoming_departures[:departure_list_north] = insert_at_index(countdown_time, true)
            else
              @upcoming_departures[:departure_list_south] = insert_at_index(countdown_time, false)
            end
          end
        end
      end
    end
  end

  def get_seconds_remaining time
    time.modulo(1) * 60
  end

  def insert_at_index countdown_time, is_north_bound
    # grab which array we need
    countdown_arry = is_north_bound ?
                     @upcoming_departures[:departure_list_north] :
                     @upcoming_departures[:departure_list_south]
    # find the index of where this time belongs in the array
    insert_index = get_insert_index(countdown_arry, countdown_time);
    # if countdown_time is the largest value for the array...
    if insert_index == nil
      countdown_arry.push(countdown_time)
    else
      # otherwise, insert it at the index we found
      countdown_arry.insert(insert_index, countdown_time)
    end
  end

  def get_insert_index arry, elm
    # find the index where to insert this countdown_time
    insert_index_arry = [*arry.each_with_index].bsearch{|x, _| x > elm}
    # we got an index to insert?
    if(insert_index_arry != nil)
      insert_index = insert_index_arry.last
    end
    # return the index or nil
    insert_index
  end
end
