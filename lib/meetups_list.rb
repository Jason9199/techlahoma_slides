require 'net/http'
require 'json'
require_relative 'event'
require_relative 'venue'
require 'date'

class MeetupsList
  NAMES = [
    'big-data-in-oklahoma-city',
    'freecodecampokc',
    'devopsokc',
    'okc-fp',
    'okc-js',
    'okc-lugnuts',
    'okc-osh',
    'okc-ruby',
    'okc-sharepoint-user-group',
    'okc-wordpress-users-group',
    'okc-sharp',
    'okcjug',
    'okcphp',
    'okcpython',
    'okcsql',
    'oklahoma-game-developers',
    'refresh-okc',
    'shecodesokc',
  ]

  def next_events
    @next_events ||= get_next_events
  end

  private

  def get_next_events
    NAMES.map do |name|
      path = '/' << name << '/events'
      events = JSON.parse(Net::HTTP.get('api.meetup.com', path))
      events.map do |event|
        venue = Venue.new(
          name:    event['venue']['name'],
          address: event['venue']['address_1'],
          city:    event['venue']['city'],
          country: event['venue']['country'],
          state:   event['venue']['state']
        )
        Event.new(
          group:    event['group']['name'],
          title:    event['name'],
          duration: event['duration'].to_i / 3600000,
          date:     Date.parse(event['local_date']),
          time:     Time.parse(event['local_time']),
          venue:    venue
        )
      end.sort_by { |event| event.date }.first
    end.compact.sort_by { |event| event.date }
  end
end
