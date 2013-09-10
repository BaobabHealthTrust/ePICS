class ApplicationController < ActionController::Base
  #protect_from_forgery
  before_filter :perform_basic_auth, :except => ['login','logout','authenticate',
    'store_room_printable','drug_availability_printable','monthly_report_printable',
    'daily_dispensation_printable','disposed_items_printable','expired_items_printable'
  ]

  protected                                                                     
                                                                                
  def perform_basic_auth
    if session[:user_id].blank?
      respond_to do |format|                                                    
        format.html { redirect_to :controller => 'user',:action => 'logout' }   
      end                                                                       
    elsif not session[:user_id].blank?
      User.current = User.find(session[:user_id])
    end                                                                         
  end 

  def print_and_redirect(print_url, redirect_url, message = "Printing, please wait...", show_next_button = false, patient_id = nil)
    @print_url = print_url
    @redirect_url = redirect_url
    @message = message
    @show_next_button = show_next_button
    @patient_id = patient_id
    render :template => 'print/print', :layout => nil
  end
  
end
