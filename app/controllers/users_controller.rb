class UsersController < ApplicationController

  def new
    @user = User.new
    render :layout => 'sessions'
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      self.current_user = @user
      redirect_to root_path
    else
      render 'new', :layout => 'sessions'
    end
  end

end
