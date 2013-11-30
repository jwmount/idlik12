#require 'debugger'
class ApplicationController < ActionController::Base
  include Authentication
  include AuthenticatedSystem 

  helper :all
  helper_method :current_user_session, :current_user, :show_links?
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

# protect_from_forgery :secret => '9847618af6620f8564a5f7ef12f48a5a'
# before_filter { |c| Authorization.current_user = c.current_user }

  
  def FB_init
    update_page do |page|
      page.insert_html :bottom, 'list', "<li>#{@item.name}</li>"
      page.visual_effect :highlight, 'list'
      page.hide 'status-indicator', 'cancel-link'
    end
  end
  
  def permission_denied
    flash[:error] = "Sorry, you are not allowed to access that page."
    redirect_to root_url
  end


   def show_links?
     ['yes', 'Yes', 'YES'].include? ENV['SHOW_LINKS']
   end

   def invite_member params
     @host = current_user
     @friend = User.find_by_email params[:user][:email]

     #Add @friend's email and name to host's list of friends (or create it if this is first one!)
     begin
       @host.friends[@friend.email] = @friend.name
     rescue
       flash[:notice] = "Problem with friends here"
#       @host.friends << {@friend.email, @friend.username}
     end

     # Put @host's credentials in @friend's list
     begin
       @friend.friends[@friend.email] = @friend.name
     rescue
       flash[:notice] = "Problem with friends here"
       #@friend.friends = {@friend.email, @friend.username}
     end

     # this appears to be a duplication of params passed but it works.  ?
     if @host.save and @friend.save
       params[:user][:message] = params[:message]
       MemberMailer.deliver_invitation(params[:user], @host.email, params[:message] )
       flash[:notice] = "You've invited Idlika member #{@friend.name}.  You can invite someone else now."
     else
       flash[:notice] = "Your invitation to Idlika member #{@friend.name} using #{@friend.email} could not be created.  " 
     end
   end
   
   def invite_non_member params
     @host = current_user
     @friend = User.new
     
     @friend.name = params[:user][:name]
     @friend.password = ENV['INVITATION_PASSWORD']
     @friend.password_confirmation = ENV['INVITATION_PASSWORD']
     @friend.email = params[:user][:email]
     @friend.terms_accepted_cb = false

     #Add email and name to host's list of friends (or create it if this is first one!)
     begin
       @host.friends[@friend.email] = @friend.name
     rescue
       flash[:notice] = "Problem with friends here"     	
       #@host.friends = {@friend.email, @friend.username}
     end
     
     begin
       @friend.friends[@host.email] = @host.name
     rescue
       flash[:notice] = "Problem with friends here"     	     	
       #@friend.friends = {@host.email, @host.username}
     end
          
     if @host.save and @friend.save!
       #New invitation accounts need corresponding registries
       @registry = Registry.new(:name=>"#{ENV['DEFAULT_REGISTRY_NAME']}", :description=>"Items added recently.", :user_id=>@friend.id)
       @registry.save!
       MemberMailer.deliver_invitation(params[:user], @host.email)
       flash[:notice] = "You've invited #{@friend.name} at #{@friend.email} to visit you on Idlika.  You can invite someone else now."
     else
       flash[:warning] = "Your invitation to #{@friend.name} with email #{@friend.email} could not be created.  " +
                        "Usually this means #{@friend.name} is already a member and #{@friend.email} is already taken."
     end
 end
   
#
# private user management via Authlogic
#
  private

  def require_user
    unless current_user
      flash[:notice] = "You must be logged in to access more pages -- register with us!"
      redirect_to root_url
    end
  end

   def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
   end

  # current_user can only be altered by login/logout
  def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
  end   
end

