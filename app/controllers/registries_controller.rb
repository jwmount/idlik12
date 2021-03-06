class RegistriesController < ApplicationController

  layout 'application'  

  before_filter :require_user 
  before_filter :find_user

  def index
    if session[:current_friend].nil?
      redirect_to user_registry_path(@user, @user.registries )
    else
      redirect_to :controller => 'gifts', :action => 'select_friend', :friend_id => session[:current_friend].id
    end
  end

  # details about a registry
  def show
    @action = session[:current_friend].nil? ? 'index' : 'select_friend'
    respond_to do |format|
      # work out named path at some point
      format.html { redirect_to :controller => 'gifts', :action => "#{@action}",  :registry_id => params[:id] }
      format.xml  { render :xml => @registry }
    end
  end

  # GET /registries/new
  # GET /registries/new.xml 
  def new
    @registry = @user.registries.new

    respond_to do |format|
       format.html  # new.html.erb
       format.xml  { render :xml => @registry }
     end
  end

  # GET /registries/1/edit
  def edit
    @registry = @user.registries.find(params[:id])
  end

  # POST /registries
  # POST /registries.xml
  def create
    @registry = @user.registries.new(registry_params)

    respond_to do |format|
      if @registry.save
        flash[:notice] = 'Registry was successfully created.'
        format.html { redirect_to user_registry_path(@user, @registry) }
        format.xml  { render :xml => @registry, :status => :created, :location => [ @user, @registry] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @registry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /registries/1
  # PUT /registries/1.xml
  def update
    @registry = @user.registries.find(params[:id])

    respond_to do |format|
  #    if @registry.update_attributes(params[:registry])
      if @registry.update_attributes(registry_params)
        flash[:notice] = 'Registry was successfully updated.'
        format.html { redirect_to([@user,@registry]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @registry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /registries/1
  # DELETE /registries/1.xml
  def destroy
    @registry = Registry.find(params[:id])
    @registry.destroy
    logger.info "*-*-*-*-* #{@registry.name} deleted by #{@user.name}."

    respond_to do |format|
      format.html { redirect_to( user_gifts_url(@user)) }
      format.xml  { head :ok }
    end
  end

  
# + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
private

  def find_user
    @user = current_user
    logger.info "*-*-*-*-* registries_controller.find_user: @user => #{@user.name}, params[:id]=>#{params[:id]}."
  end
  
  # Using a private method to encapsulate the permissible parameters is just a good pattern
  # since you'll be able to reuse the same permit list between create and update. Also, you
  # can specialize this method with per-user checking of permissible attributes.
  def registry_params
    params.require(:registry).permit(:name, :description)
  end

end
