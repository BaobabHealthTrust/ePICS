class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :check_login, :except => ['login','enter_workstation', 'locations','authenticate']



  def check_login

    raise session.to_yaml
    if session[:user_id].blank?

      redirect_to '/user/login'

    else

    end



  end

end
