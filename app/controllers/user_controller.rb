class UserController < ApplicationController
  def login


  end

  def logout
    reset_session
    redirect_to '/login'
  end

  def authenticate
    user = User.check_authenticity(params[:password], params[:login]) rescue nil
    if user.blank?
      flash[:error] = "Invalid user name or password"
      redirect_to '/user/login'
    else
      session[:user_id] = user.id
      redirect_to '/user/enter_workstation' and return
      redirect_to '/' and return
    end
  end

  def locations
    location = EpicsLocation.find_by_epics_location_id(params[:location]) rescue nil
    if location.blank?
      flash[:error] = "Invalid workstation location"
      redirect_to '/user/enter_workstation'
    else
      session[:location_name] = location.name
      session[:location_id] = location.id
      if location.epics_location_type.name == "Management"
         redirect_to root_path
      else
        #redirect_to "/home/dispensary"
        redirect_to '/'
      end
    end
  end

end
