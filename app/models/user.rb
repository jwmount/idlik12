class User < ActiveRecord::Base
  acts_as_authentic 
    
  has_many :registries, :dependent => :destroy
  
  serialize :friends
  
  validates_presence_of :username
  validates_presence_of :email
#  validates_acceptance_of :terms_accepted_cb


  def message
    message ||= "message"
  end
      
  def role_symbols
    roles.map do |role|
      role.username.underscore.to_sym
    end
  end
  

end

