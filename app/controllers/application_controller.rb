class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :check_login



  def check_login

    redirect_to '/user/login.html'

  end

end
