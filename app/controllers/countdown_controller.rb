class CountdownController < ApplicationController
  def index
    countdown_list = CountdownList.new()
    render json: countdown_list.upcoming_departures.sort_by! {
      |dept| dept.arrival
    }
  end
end
