class Gift < ActiveRecord::Base
 
 belongs_to :user
 belongs_to :registry
 has_many   :donors
 has_many   :sources, :dependent => :destroy
  
 serialize :who_can_see

 Gift::NO_CURRENT_REGISTRY = "No registry found, there is no default registry yet."
 Gift::GIFT_REGISTRY_MISSING = "Gift is not assigned to a registry."
 Gift::GIFT_INDUCTED         = "Gift is now part of your collection."
  GIFT_UPDATE_OK = 'Gift was successfully updated.'
 

 has_attached_file :photo,
  :styles => {
     :tiny => "50x50#",
     :preview => "175x175>",
     :large => "300x300"
   },
   :default_style => :tiny,
   :default_url => "/assets/idlika_logo.png",
   :storage => :s3,
   :s3_credentials => "#{RAILS_ROOT}/config/amazon_s3.yml",    # Good, clear msg if not visible
   # visible to client, what she sees
   :url  => ":attachment/:id/:style/:filename",
   # :path is actual file path, also the key, file name is bucket + key, this is the Heroku default
   :path => ":attachment/:id/:style/:filename",
   :bucket => ENV["S3_BUCKET"]
   
 # Paperclip Validations
 validates_attachment_presence :photo
 validates_attachment_size :photo, :less_than => 5.megabytes
 #validates_attachment_size :photo, :less_than => 1.megabyte, 
 # :unless => Proc.new { |imports| imports.photo_file_name.blank? }
 validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/tiff']

# Instance Validations
 validates_presence_of :registry_id
 validates_associated :registry
 validates_associated :user


  
  # Possibly none, some, or all of @gifts may visible.
  # @user is may be current_user or the person being visited.
  # so what gifts is current_user allowed to see?  Answer is in Donor.  Result may be nil.
  def can_see?
    return gifts if id.nil?
    donors = Donor.find( :all, :conditions => [ "allow_id = ?", id ] )
    gifts_allowed = donors.collect {|x| x.gift_id } 
    gifts.find( gifts_allowed, :order => "created_at DESC" )
  end

#
# D E F A U L T S
#
  after_initialize :defaults

  def defaults
     unless persisted?
    end
  end

  
end
