class SessionsController < ApplicationController
  def create
    client_id = "482f66376793accf0314"
    client_secret = "7cefb86e005e98a9a8eccc33b0f4144520666c5d"
    code = params[:code]

    conn = Faraday.new(url: 'https://github.com', headers: {'Accept' => 'application/json'})

    response = conn.post('/login/oauth/access_token') do |req|
      req.params['code'] = code
      req.params['client_id'] = client_id
      req.params['client_secret'] = client_secret
    end

    data = JSON.parse(response.body, symbolize_names: true)
    access_token = data[:access_token]

    conn2 = Faraday.new(
      url: 'https://api.github.com', 
      headers: {
        'Authorization': "token #{access_token}"
      }
    )
    response2 = conn2.get('/user')
    data2 = JSON.parse(response2.body, symbolize_names: true)

    user = User.find_or_create_by(uid: data2[:id])
    user.username = data2[:login]
    user.uid = data2[:id]
    user.token = access_token
    user.save

    session[:user_id] = user.id

    require 'pry'; binding.pry
    redirect_to dashboard_path
  end
end