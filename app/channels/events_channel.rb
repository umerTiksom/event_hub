class EventsChannel < ApplicationCable::Channel

  def subscribed
    stream_from "events"
  end

  def unsubscribed
    stop_all_streams
  end

end