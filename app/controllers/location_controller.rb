class LocationController < ApplicationController
  def index
    @locations = EpicsLocation.all
    render :layout => false
  end

  def new
    @locations = EpicsLocation.new
    @location_type_map = EpicsLocationType.all.map{|location_type|[location_type.name,location_type.epics_location_type_id]}
  end

  def create 
    @location = EpicsLocation.new
    @location.name = params[:location][:name]
    @location.description = params[:location][:description]
    @location.epics_location_type_id = params[:location][:location_type_id]
    if @location.save!
       redirect_to :action => :index
    else
       redirect_to :action => :new
    end

  end

  def edit
    @location = EpicsLocation.find(params[:location])
    @location_type_map = EpicsLocationType.all.map{|location_type|[location_type.name,location_type.epics_location_type_id]}
  end

  def update
    @location = EpicsLocation.find(params[:location][:location_id])
    @location.name = params[:location][:name]
    @location.description = params[:location][:description]
    @location.epics_location_type_id = params[:location][:location_type_id]
    
    if @location.save!
       redirect_to :action => :index
    else
       redirect_to :action => :edit, :location_id => params[:location][:location_id]
    end
  end

  def void
    @location = EpicsLocation.find(params[:location_id])
    @location.voided = 1
    @location.save!
		render :text => 'showMsg("Record Deleted!")'
  end

end
