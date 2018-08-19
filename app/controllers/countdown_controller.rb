class CountdownController < ApplicationController
  def index
    countdown_list = CountdownList.new()
    render json: countdown_list.upcoming_departures
  end
end
