#require 'debugger'
class UserSessionsController < ApplicationController
 Authlogic::Session::Base.controller = Authlogic::ControllerAdapters::RailsAdapter.new(self) 
 layout 'welcome'

  # NOTE:  AuthLogic will automatically use :email for login if 'login' in not defined in schema.
  # http://stackoverflow.com/questions/5573208/setting-up-authlogic-i-keep-hitting-undefined-method-login-for-usersession
  def new
    @user_session = UserSession.new
  end

  # creates user's logon session    
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to gifts_path
    else
      render :action => 'new'
    end
  end
  
  def destroy
    current_user_session.destroy
    logger.info "***** @user_session terminated."
    redirect_to root_url
  end
  
  def orient
  end
  
  
end
