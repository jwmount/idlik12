class HomeController < ApplicationController
  protect_from_forgery
  #skip_before_action :verify_authenticity_token, if: :json_request?#  filter_resource_access
  layout 'welcome'
  
  def index
  end

  def contact
  end

  def how
  end
  
  def what
  end

  def faq
  end
  
  def terms
  end
  
  def privacy
  end
      
end
