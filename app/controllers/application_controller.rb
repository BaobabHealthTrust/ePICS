class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :check_login, :except => ['login','enter_workstation', 'locations','authenticate']

end
