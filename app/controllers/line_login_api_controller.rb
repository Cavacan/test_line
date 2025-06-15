class LineLoginApiController < ApplicationController
  require 'typhoeus'
  require 'securerandom'

  before_action :require_login  # Sorceryでログイン済みのユーザーのみ

  def login
    session[:state] = SecureRandom.urlsafe_base64
    redirect_uri = CGI.escape(line_login_api_callback_url)
    state = session[:state]
    scope = 'profile openid'

    client_id = ENV['LINE_LOGIN_CHANNEL_ID']
    authorization_url = "https://access.line.me/oauth2/v2.1/authorize?" \
                        "response_type=code&client_id=#{client_id}&redirect_uri=#{redirect_uri}&state=#{state}&scope=#{scope}"

    redirect_to authorization_url, allow_other_host: true
  end

  def callback
    if params[:state] == session[:state]
      line_user_id = get_line_user_id(params[:code])

      if line_user_id
        current_user.update(line_user_id: line_user_id)
        redirect_to home_path, notice: 'LINEアカウントを連携しました'
      else
        redirect_to home_path, alert: 'LINEユーザーIDの取得に失敗しました'
      end
    else
      redirect_to root_path, alert: '不正なアクセスです'
    end
  end

  private

  def get_line_user_id(code)
    token_data = get_token_data(code)
    access_token = token_data["access_token"]
    return nil if access_token.blank?

    profile = get_profile(access_token)
    profile["userId"]  # Messaging API用
  end

  def get_token_data(code)
    url = 'https://api.line.me/oauth2/v2.1/token'
    response = Typhoeus::Request.post(url, body:{
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: line_login_api_callback_url,
      client_id: ENV['LINE_LOGIN_CHANNEL_ID'],
      client_secret: ENV['LINE_LOGIN_CHANNEL_SECRET']
    }, headers: { 'Content-Type' => 'application/x-www-form-urlencoded' })

    JSON.parse(response.body)
  end

  def get_profile(access_token)
    url = 'https://api.line.me/v2/profile'
    response = Typhoeus::Request.get(url, headers: {
      'Authorization' => "Bearer #{access_token}"
    })
    JSON.parse(response.body)
  end
end