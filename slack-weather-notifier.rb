require 'json'
require 'open-uri'
require 'slack/incoming/webhooks'

def post_to_slack text, attachments: attachments
  slack = Slack::Incoming::Webhooks.new ENV['WEBHOOK_URL']
  slack.post text, attachments: attachments
end

def temperature weather, maxmin
  temperature = weather['temperature'][maxmin]

  if temperature.nil?
    "---"
  else
    "#{temperature['celsius']}℃"
  end
end

def post_weather_for weather, link: link
  min     = temperature weather, 'min'
  max     = temperature weather, 'max'

  title   = "#{weather['dateLabel']}の天気 『#{weather['telop']}』"
  text    = "最低気温 #{min}\n最高気温 #{max}\n#{weather['date']}"

  attachments = [{
    title: title,
    title_link: link,
    text: text,
    image_url: weather['image']['url'],
    color: "#7CD197"
  }]

  post_to_slack "", attachments: attachments
end

uri = 'http://weather.livedoor.com/forecast/webservice/json/v1?city=400010'

res         = JSON.load(open(uri).read)
title       = res['title']
provider    = res['copyright']['provider'].first['name']
description = res['description']['text'].delete("\n")
link        = res['link']
today       = res['forecasts'][0]
tomorrow    = res['forecasts'][1]

attachments = [{
  title: title,
  title_link: link,
  text: provider
}]

post_to_slack description, attachments: attachments
post_weather_for today, link: link
post_weather_for tomorrow, link: link
