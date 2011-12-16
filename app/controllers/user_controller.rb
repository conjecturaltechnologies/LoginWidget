class UserController < ApplicationController
  
  before_filter :login_required, :only=>['welcome','change_password','hidden']
  
  def signup
    @user = User.new(@params[:user])
    if request.post?
      if @user.save
        session[:user] = User.authenticate(@user.login, @user.password)
        flash[:message] = "Registration Successful"
        redirect_to letter_path
      else
        flash[:warning] = "Registration Failed with error code: PLACEHOLDER"
      end
    end
  end

  def login
    if request.post?
      if session[:user] = User.authenticate(params[:user][:login],params[:user][:password])
        flash[:message] = "Login successful"
        redirect_to_stored
      else
        flash[:warning] = "Login failed"
      end
    end
  end

  def logout
    session[:user] = nil
    flash[:message] = 'Logged out'
    redirect_to :action => 'login'
  end

  def delete
    
  end

  def edit
    
  end

  def forgot_password
    if request.post?
      u = User.find_by_email(params[:user][:email])
      if u and u.send_new_password
        flash[:message] = "We've sent a temporary password to your email.  Please login and change passwords by following this link: PLACEHOLDER"
        redirect_to :action =>'login'
      else
        flash[:warning] = "Couldn't send a new password, probably because we don't have your email address"
      end
    end
  end
  
  def change_password
    @user=session[:user]
    if request.post?
      @user.update_attributes(:password=>params([:user][:password]), :password_confirmation => params[:user][:password_confirmation])
      if @user.save
        flash[:message]="Password Changed"
      end
    end
  end
  
  def welcome
    
  end
  
  def hidden
    
  end

end
