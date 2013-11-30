class User < ActiveRecord::Base
  acts_as_authentic 
    
  has_many :donors 
  has_many :gifts,      :dependent => :destroy
  has_many :registries, :dependent => :destroy
  has_many :roles,      :through => :registries, :source => :user
  has_many :sources,    :dependent => :destroy
  
  serialize :friends
  
  validates_presence_of :name
  validates_presence_of :email
#  validates_acceptance_of :terms_accepted_cb


  def message
    message ||= "message"
  end
      
  def role_symbols
    roles.map do |role|
      role.name.underscore.to_sym
    end
  end
  

end

