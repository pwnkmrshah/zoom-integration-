Rails.application.routes.draw do
  root 'meetings#index'
# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get '/authorize', to: 'oauth#authorize'
  get '/callback', to: 'oauth#callback'
  get '/zoom_meeting', to: 'meetings#zoom_meeting'
  post '/schedule_zoom_meeting', to: 'meetings#schedule_zoom_meeting'
  get '/meeting_scheduled', to: 'meetings#meeting_scheduled'
end
