# app/controllers/oauth_controller.rb
class OauthController < ApplicationController
  require 'net/http'
  require 'uri'
  
  def authorize
    redirect_to zoom_authorization_url, allow_other_host: true
  end

  def callback
    code = params[:code]
    access_token = exchange_authorization_code_for_token(code)
    session[:access_token] = access_token
    redirect_to zoom_meeting_url
  end

  private

  def zoom_authorization_url
    zoom_authorization_params = {
      client_id: ENV['ZOOM_CLIENT_ID'],
      redirect_uri: ENV['ZOOM_REDIRECT_URI'],
      response_type: 'code'
    }
    "https://zoom.us/oauth/authorize?#{zoom_authorization_params.to_query}"
  end

  def exchange_authorization_code_for_token(code)
    uri = URI.parse('https://zoom.us/oauth/token')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(
      'grant_type' => 'authorization_code',
      'code' => code,
      'redirect_uri' => ENV['ZOOM_REDIRECT_URI'],
      'client_id' => ENV['ZOOM_CLIENT_ID'],
      'client_secret' => ENV['ZOOM_CLIENT_SECRET']
    )

    response = http.request(request)
    token_data = JSON.parse(response.body)

    access_token = token_data['access_token']
    refresh_token = token_data['refresh_token']
    ZoomMeeting.create(access_token: token_data['access_token'], refresh_access_token:token_data['refresh_token']) if response.is_a?(Net::HTTPSuccess)
    return token_data['access_token']
  end

end
