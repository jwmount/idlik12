class Registry < ActiveRecord::Base

  belongs_to :user
  has_many :gifts, :dependent => :destroy
  
  validates_associated :user
#  validates_exclusion_of :name, :in => %w( ENV['DEFAULT_REGISTRY_NAME'] ), :message => "'Recently Added' is reserved. Please choose another name."

#
# D E F A U L T S
#
  after_initialize :defaults

  def defaults
     unless persisted?
    end
  end
    
  
end
