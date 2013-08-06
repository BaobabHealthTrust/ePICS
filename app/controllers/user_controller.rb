class UserController < ApplicationController
  def login


  end

  def logout

  end

  def authenticate


    user = User.check_authenticity(params[:password], params[:login])

    if user.blank?
      flash[:error] = "Invalid user name or password"
      redirect_to '/user/login'
    else
      redirect_to '/user/enter_workstation'
    end

  end

  def enter_workstation

  end

  def locations

  end

end
