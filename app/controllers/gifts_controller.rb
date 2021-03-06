#require 'debugger'
class GiftsController < ApplicationController
  layout 'application'
  protect_from_forgery 
  #skip_before_action :verify_authenticity_token, if: :json_request?  
  before_filter :require_user 

  before_filter :find_user
  before_filter :find_friend, :except => :select_friend_registry
 

  # Display gifts user is permitted to see; owner can see all.
  # If there are no registries, cannot be any gifts.  So notify user and redirect_to ????.
  # If there are registries, hold onto registry[0] (why?) and return what's in there as appropriate.
  def index
    if @user.registries.empty?
      flash[:info] = "No registries or gifts found, time to create some?"
    else
      registries = @user.registries
      session[:current_registry] = registries[0].id
      @registry = Registry.find session[:current_registry]
      @gifts = @registry.gifts
    end
    @gifts
  end


  # set @registry passed in to current so gifts are collected in it
  def index_for_registry
    @registry = Registry.find params[:registry_id]
    @gifts = @registry.gifts
    render :action => 'index'
  end

  # Display gifts of selected friend.  At this point we only know the friend by id
  def index_for_friend
      session.clear
      @friend = User.find_by_name params[:friend_name]
      session[:current_friend] = @friend
      @friend = session[:current_friend]
      @gifts = @friend.gifts
      logger.info("*-*-*-* gifts_controller.select_friend: id: #{@friend.id}, name: #{@friend.name}" )
  end
      
  # REMINDER:  before_filter :find_friend, :except => :select_friend_registry
  def select_friend_registry
    session[:current_registry] = Registry.find params[:registry_id]
    @registry = Registry.find params[:registry_id]
    @friend = User.find params[:id]
    @gifts = @registry.gifts
    render :action => 'friend_index'
  end
  
  # @gift identifies its user via session[:current_friend].
  def show
    if @user.registries.empty?
      render gifts_path
    else
      @gift = Gift.find params[:id]
      if @gift.user.id != @user.id
        @user = User.find @gift.user.id
      end
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @gift }
    end
  end


  def new
    @gift = Gift.new
    @registries = @user.registries
  end

  def edit
    @gift = Gift.find params.required(:id)
  end

  def images
  end
  
  def test_URL
      @url = "https://graph.facebook.com/19292868552"
      begin
        result = Net::HTTP.get(URI.parse(@url))
        logger.info "*-*-*-*_* tropo record_call uri:  uri = #{@url}"
        call_to_record_success(@sender.id, filename, params[:keywords]) if result.match /(<session><success>true<success>)/
      rescue
        logger.info "*-*-*-*_* attempt to record_call uri:  uri = #{@url} FAILED."
      end
      render :show
    end
  
  # New gifts must go into a registry.  But WHY is this value lost in the gift_params call?
  def create
    @gift = @user.gifts.create(gift_params)
    @gift.registry_id = params[:registry_id]
    @registries = @user.registries

    respond_to do |format|
      if @gift.save!
        flash[:notice] = Gift::GIFT_INDUCTED
        format.html { redirect_to( gift_path(@gift) ) }
        format.xml  { render :xml => @gift, :status => :created, :location => @gift }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @gift.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @gift = Gift.find params[:id]
    respond_to do |format|
      if @gift.save
        flash[:notice] = Gift::GIFT_UPDATE_OK
        format.html { redirect_to gifts_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @gift.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    Gift.destroy params[:id]
    respond_to do |format|
      format.html { redirect_to(gifts_url) }
      format.xml  { head :ok }
    end
  end
  
  # invoked from edit view to control granting & revoking view privledges by friends
  def gift_toggle

    @gift = Gift.find params[:gift_id]

    # .nil? doesn't seem to work here?
    if params[params[:friend]] == "null"
      # turn disallow viewing, so find it, if found, destroy it
      # they can't see gift nn owned by user uu
      @friend_allowed = User.find_by_name( params[:friend], :select => :id )
      @donors = Donor.find_all_by_gift_id( @gift.id, :conditions => [ "allow_id = ?", @friend_allowed.id ] )

      # if Donor.destroy_all(["'user_id' = ? AND  'gift_id' = ?", @friend_allowed.id, @gift.id])
      @donors.each do |d|
        d.delete
        logger.info( "\n*-*-*-*-* gifts_controller.gift_toggle -- DENY permission to view gift_id #{@gift.id} to user_id #{@friend_allowed.id}, by user: #{@user.id}.\n")
      end
    else
      @donor = Donor.new
      @donor.allow_id = @user.id
      @friend_allowed = User.find_by_name( params[params[:friend]], :select => :id )
      @donor.allow_id = @friend_allowed.id
      @donor.gift_id = params[:gift_id]
      if @donor.save
        logger.info( "\n*-*-*-*-* gifts_controller.gift_toggle --  GRANT permission to view gift_id #{@gift.id} to user_id #{@friend_allowed.id}, by user: #{@user.id}.\n")
      end
    end

    # Here is maintained the hash of friends and permissions
    # Logically this may be redundant with the Donor model, t.b.d.    
    # redirect at bottom is NOT expendable!
    @gift = Gift.find params[:gift_id]
    friend = User.find_by_name params[:friend]

    @value = params[:friend]
    @value = params[@value]
#    @permit = params[@value].nil? ? {friend.username, 'no'} : {friend.username, 'yes'}  
    @permit = params[@value].nil? ? friend.name == 'no' : friend.name == 'yes'

    @gift.who_can_see = {}
    @gift.who_can_see.merge! @permit
    
    @gift.null_gates
    if @gift.save
        logger.info( "\n*-*-*-*-* gifts_controller.gift_toggle -- gift_id #{@gift.id}, user_id #{friend.id}, @gift.who_can_see: #{@gift.who_can_see}.\n")
      else
        format.xml  { render :xml => @gift.errors, :status => :unprocessable_entity }
    end
    redirect_to edit_user_gift_path(@user, @gift)
  end
  
  def registry_toggle
    @gift = Gift.find params[:gift_id]
    @gift.registry_id = params[:registry_id]
    @gift.save
    redirect_to :action => 'edit', :id => @gift
  end
 
  def copy_gift
    flash[:notice] = "Feature under development."
    redirect_to :action => 'show', :id => @gift.id
  end
   
  def give_gift
    flash[:notice] = "Feature under development."
    redirect_to :action => "show", :id => @gift.id
  end
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

  def find_friend
    begin
      @friend = User.find session[:current_friend]
    rescue
      session[:current_friend] = nil 
    end
    @friend = session[:current_friend]
  end
  
  def find_registry
    begin
      session[:current_registry] = Registry.find session[:current_registry].id
    rescue
      session[:current_registy] = nil
    end
    @registry = session[:current_registry]
  end
  
  # current_user is person logged on.
  def find_user
    begin
      @user = current_user
      session[:current_friend] = nil
    rescue
      render :text => "No user could be established.  Probably this is an active session but the database has been cleared.   
      Close your browser and try again (this will clear the session)."
      system.exit
    end
    find_registry
  end #find_user

#
# private    
#
  private
  # Using a private method to encapsulate the permissible parameters is just a good pattern
  # since you'll be able to reuse the same permit list between create and update. Also, you
  # can specialize this method with per-user checking of permissible attributes.
  def gift_params
    params.require(:gift).permit( :description,
                                  :name,
                                  :registry_id,
                                  :source,
                                  :URL,
                                  :i_can_see,
                                  :friends_can_see,
                                  :photo,
                                  :photo_file_name,
                                  :photo_content_type,
                                  :photo_file_size,
                                  :photo_updated_at,
                                  :user_id,
                                  :who_can_see
                                  )
  end

end
 