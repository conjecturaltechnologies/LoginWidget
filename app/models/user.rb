require 'digest/sha1'

class User
  include MongoMapper::Document

  validates_length_of :login, :within => 3..40
  validates_length_of :password, :within => 5..40
  validates_presence_of :login, :email, :password, :password_confirmation, :salt
  validates_uniqueness_of :login, :email
  validates_confirmation_of :password
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"  

  attr_protected :id, :salt
  
  def self.random_string(len)
    # Generates a random password cosisting of strings and digits
    chars = ("a" .. "z").to_a + ("A".."Z")to_a + ("0".."9").to_a
    newpass = "" 
    1.upto(len) { |i| 
      newpass << chars[rand(chars.size-1)]
    }
    return newpass
  end
  
  def password=(pwd)
     @password = pwd
     self.salt = User.random_string(10) unless self.salt?
     self.hashed_password = User.encrypt(@password, self.salt)
  end
  
  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass+salt)
  end
  
  def self.authenticate(login,pwd)
    u = find(:first, :conditions=>["login = ?", login])
    return nil if u.nil?
    return u if User.encrypt(pass, u.salt) == u.hashed_password
    nil
  end
  
  def send_new_password
    new_pass = User.random_string(12)
    self.password = self.password_confirmation = new_pass
    self.save
    Notifications.deliver_forgot_password(self.email, self.login, new_pass)
  end
   
end
