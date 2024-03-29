require 'test_helper.rb'

class UserTest < Test::Unit::TestCase
    
  self.use_instantiated_fixtures  = true
  fixtures :users
  
   def test_auth 
    #check that we can login we a valid user 
    assert_equal  @vak, User.authenticate("vak", "test")    
    #wrong username
    assert_nil    User.authenticate("notvak", "test")
    #wrong password
    assert_nil    User.authenticate("vak", "wrongpass")
    #wrong login and pass
    assert_nil    User.authenticate("notvak", "wrongpass")
  end
  
  def test_passwordchange
    # check success
    assert_equal @oleg, User.authenticate("oleg", "longtest")
    #change password
    @oleg.password = @oleg.password_confirmation = "newpass"
    assert @oleg.save
    #new password works
    assert_equal @oleg, User.authenticate("oleg", "newpass")
    #old pasword doesn't work anymore
    assert_nil   User.authenticate("oleg", "longtest")
    #change back again
    @oleg.password = @oleg.password_confirmation = "longtest"
    assert @oleg.save
    assert_equal @oleg, User.authenticate("oleg", "longtest")
    assert_nil   User.authenticate("oleg", "nonbobpasswd")
  end
  
  def test_disallowed_passwords
    #check success
    #check thaat we can't create a user with any of the disallowed paswords
    u = User.new    
    u.login = "nonbob"
    u.email = "nonbob@mcbob.com"
    #too short
    u.password = u.password_confirmation = "tiny"
    assert !u.save
    assert u.errors.invalid?('password')
    #too long
    u.password = u.password_confirmation = "hugehugehugehugehugehugehugehugehugehugehugehugehuge"
    assert !u.save
    assert u.errors.invalid?('password')
    #empty
    u.password = u.password_confirmation = ""
    assert !u.save
    assert u.errors.invalid?('password')
    #ok
    u.password = u.password_confirmation = "testingvalidpwd"
    assert u.save
    assert u.errors.empty
  end
  
  def test_bad_logins
    #check we cant create a user with an invalid username
    u = User.new  
    u.password = u.password_confirmation = "bobs_secure_password"
    u.email = "okbob@mcbob.com"
    #too short
    u.login = "x"
    assert !u.save     
    assert u.errors.invalid?('login')
    #too long
    u.login = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug"
    assert !u.save     
    assert u.errors.invalid?('login')
    #empty
    u.login = ""
    assert !u.save
    assert u.errors.invalid?('login')
    #ok
    u.login = "okbob"
    assert u.save  
    assert u.errors.empty?
    #no email
    u.email=nil   
    assert !u.save     
    assert u.errors.invalid?('email')
    #invalid email
    u.email='notavalidemail'   
    assert !u.save     
    assert u.errors.invalid?('email')
    #ok
    u.email="validbob@mcbob.com"
    assert u.save  
    assert u.errors.empty?
  end


  def test_collision
    #check can't create new user with existing username
    u = User.new
    u.login = "kyle"
    u.password = u.password_confirmation = "bobs_secure_password"
    assert !u.save
  end


  def test_create
    #check create works and we can authenticate after creation
    u = User.new
    u.login      = "nonexistingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
    u.email="nonexistingbob@mcbob.com"  
    assert_not_nil u.salt
    assert u.save
    assert_equal 10, u.salt.length
    assert_equal u, User.authenticate(u.login, u.password)

    u = User.new(:login => "alex", :password => "newpassword", :password_confirmation => "newpassword", :email => "newbob@mcbob.com" )
    assert_not_nil u.salt
    assert_not_nil u.password
    assert_not_nil u.hashed_password
    assert u.save 
    assert_equal u, User.authenticate(u.login, u.password)

  end

  def test_send_new_password
    #check user authenticates
    assert_equal  @vak, User.authenticate("vak", "test")    
    #send new password
    sent = @vak.send_new_password
    assert_not_nil sent
    #old password no longer workd
    assert_nil User.authenticate("vak", "test")
    #email sent...
    assert_equal "Your password is ...", sent.subject
    #... to bob
    assert_equal @vak.email, sent.to[0]
    assert_match Regexp.new("Your username is vak."), sent.body
    #can authenticate with the new password
    new_pass = $1 if Regexp.new("Your new password is (\\w+).") =~ sent.body 
    assert_not_nil new_pass
    assert_equal  @vak, User.authenticate("vak", new_pass)    
  end

  def test_rand_str
    new_pass = User.random_string(10)
    assert_not_nil new_pass
    assert_equal 10, new_pass.length
  end

  def test_sha1
    u=User.new
    u.login      = "nonexistingbob"
    u.email="nonexistingbob@mcbob.com"  
    u.salt="1000"
    u.password = u.password_confirmation = "bobs_secure_password"
    assert u.save   
    assert_equal 'b1d27036d59f9499d403f90e0bcf43281adaa844', u.hashed_password
    assert_equal 'b1d27036d59f9499d403f90e0bcf43281adaa844', User.encrypt("bobs_secure_password", "1000")
  end

  def test_protected_attributes
    #check attributes are protected
    u = User.new(:id=>999999, :salt=>"I-want-to-set-my-salt", :login => "badbob", :password => "newpassword", :password_confirmation => "newpassword", :email => "badbob@mcbob.com" )
    assert u.save
    assert_not_equal 999999, u.id
    assert_not_equal "I-want-to-set-my-salt", u.salt

    u.update_attributes(:id=>999999, :salt=>"I-want-to-set-my-salt", :login => "verybadbob")
    assert u.save
    assert_not_equal 999999, u.id
    assert_not_equal "I-want-to-set-my-salt", u.salt
    assert_equal "verybadbob", u.login
  end
end

