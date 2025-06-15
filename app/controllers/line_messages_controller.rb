class LineMessagesController < ApplicationController
  before_action :require_login

  def send_message
    if current_user.line_user_id.present?
      LineMessenger.new.push_message(current_user.line_user_id, 'hello.')
      redirect_to home_path, notice: 'LINEにメッセージを送りました'
    else
      redirect_to home_path, alert: 'LINEアカウントが連携されていません'
    end
  end
end