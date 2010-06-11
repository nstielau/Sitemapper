require 'digest/sha1'

class User
  include MongoMapper::Document

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  key :crypted_password,          String
  key :salt,                      String
  key :remember_token,            String
  key :remember_token_expires_at, Time
  key :login,                     String
  key :email,                     String
  key :name,                      String
  key :has_delegated_seomoz_auth, Boolean, :default => false
  key :seomoz_auth_verified,      Boolean, :default => false
  key :delegated_seomoz_auth_at,  Time
  key :seomoz_secret_key,         String
  key :seomoz_access_id,          String

  has_many :graphs

  timestamps!

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  #attr_accessible :login, :email, :name, :password, :password_confirmation

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def total_distance
    return 0 if tracks.size == 0
    Track.collection.group(nil, {"user_id" => id},{"total_distance" => 0}, "function(obj,prev){prev.total_distance += obj.distance}")[0]["total_distance"]
  end

  def total_active_time
    return 0 if tracks.size == 0
    Track.collection.group(nil, {"user_id" => id},{"total_active_time" => 0}, "function(obj,prev){prev.total_active_time += obj.active_time}")[0]["total_active_time"]
  end

  protected

end
