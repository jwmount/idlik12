class Source < ActiveRecord::Base

  belongs_to :donor
  
  validates_associated :donor

end
