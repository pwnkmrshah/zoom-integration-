class MeetingsController < ApplicationController
    require 'net/http'
  require 'uri'
  def zoom_meeting
    @access_token = session[:access_token]
  end

  def authorize_user
    # Define your API endpoint and access token

    api_endpoint = URI.parse('https://api.zoom.us/v2/users/me')
    access_token = ZoomMeeting.last.access_token # Replace with your access token

    # Create an HTTP object
    http = Net::HTTP.new(api_endpoint.host, api_endpoint.port)
    http.use_ssl = (api_endpoint.scheme == 'https')

    # Create an HTTP GET request
    request = Net::HTTP::Get.new(api_endpoint.request_uri)
    request['Authorization'] = "Bearer #{access_token}"

    # Send the GET request
    response = http.request(request)

    # Check if the response is successful (HTTP status code 200)
    if response.is_a?(Net::HTTPSuccess)
      # Process the response body
      response_body = response.body
      puts "Response Body: #{response_body}"
    else
      # Handle the error, e.g., display the HTTP status code and response body
      puts "Request failed with HTTP status code: #{response.code}"
      puts "Response Body: #{response.body}"
    end
  end
  

  def schedule_zoom_meeting
    authorize_user
    zoom_api_key = ENV['ZOOM_CLIENT_ID']
    zoom_api_secret = ENV['ZOOM_CLIENT_SECRET']

    uri = URI.parse('https://api.zoom.us/v2/users/me/meetings')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request['authorization'] = "Bearer #{session[:access_token]}"

    request.body = {
      topic: 'Meeting Title',
      type: 1, # 1 for instant meeting
      start_time: Time.now.iso8601,
      duration: 60, # Meeting duration in minutes
      settings: {
        host_video: true,
        participant_video: true
      }
    }.to_json

    response = http.request(request)
    meeting_data = JSON.parse(response.body)
    
    Rails.logger.info "Meeting Data:- #{meeting_data}"
    MeetingDetail.create(uuid: meeting_data['uuid'], host_id: meeting_data['host_id'], host_email: meeting_data['host_email'], topic: meeting_data['topic'], start_url: meeting_data['start_url'], join_url: meeting_data['join_url'], password: meeting_data['password'])
    redirect_to meeting_scheduled_url, notice: 'Meeting Scheduled'
  end

  def meeting_scheduled
    @meeting_data = MeetingDetail.last
  end

end
