class UserSessionsController < ApplicationController

  def new; end

  def create
    @user = login(params[:email], params[:password])

    if @user
      redirect_back_or_to home_path
    else
      render :new
    end
  end
end
