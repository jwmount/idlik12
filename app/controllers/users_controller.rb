class UsersController < ApplicationController
  before_filter :require_user, :except => :new
#  before_filter :mailer_set_url_options
  layout 'welcome'
     
  def index
    @users = User.all :order => :name
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = current_user
  end

  def create
    unless params[:user][:terms_accepted_cb]
      flash[:notice] = Constants::TERMS_AND_CONDITIONS
      redirect_to :action => 'new'
    else
      @user = User.new(user_params)
      Role.all.each do |r|
        @user.role_id = r.id if r.name == "guest"
      end
      if @user.save!
        flash[:notice] = Constants::REGISTRATION_SUCCESSFUL 
        UserMailer.welcome_email(@user).deliver
        redirect_to orient_path
      else
         render :action => 'new'
       end
    end
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = Contants::MODIFIED_PROFILE_OK
      redirect_to user_gifts_url(@user)
    else
        render :action => 'edit'
    end
  end
  
  def destroy
    User.destroy params[:id]
    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
  
  def invite
    @user = current_user
    @friend = User.new
  end

  # Design Notes
  # It can happen that a user has no friends established (registered on own initiative, for example).
  # For some reason the @invited_friend hash may be nil (actually {nil, nil}).  Skip the update in this case.
  def invitation

    # Person being invited, may be a member already, or not; based on email uniqueness
    if User.exists?(:email => "#{params[:user][:email]}")
      invite_member params
    else
      invite_non_member params
    end
    logger.info "*-*-*-* #{flash[:notice]}"  unless flash[:notice].nil?
    logger.info "*-*-*-* #{flash[:warning]}" unless flash[:warning].nil?
    
    # do not redirect as flash will be lost; provide @user for use in _sidebar.
    # this needs some work as it looks like a partial instead of a render would work.
    @user = current_user
    render :action => :invite
  end
#
# = P R I V A T E = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
#
private

# TEMPORARY -- turned off Thurs pm 7-22 to enable app to run, email may not work
# Turned on Nov 19, 2013 to reactivate as part of idlik12
#  def mailer_set_url_options
#    MemberMailer::Base.default_url_options[:host] = request.host_with_port
#  end

#
# S T R O N G  P A R A M E T E R S
#  
  #attr_accessible :username, :email, :password, :password_confirmation, :terms_accepted_cb
  def user_params
    params.require(:user).permit( :name,
                                  :email,
                                  :password,
                                  :password_confirmation,
                                  :terms_accepted_cb
                                  )
  end
 
end
