class EpicsExchangeController < ApplicationController

  def create

    session[:exchange] = nil
    exchange_hash = Hash.new()
    exchange_hash[:exchange_facility] = params[:location]
    exchange_hash[:exchange_date] = params[:exchange_date]
    session[:exchange] = exchange_hash

    unless session[:exchange].nil?
      redirect_to :controller => :epics_exchange, :action => :new
    else
      redirect_to :action => :new
    end


  end

  def new

    render :layout => 'custom'
  end

  def index

  end

end
