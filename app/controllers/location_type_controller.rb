class LocationTypeController < ApplicationController
  def index
    @location_types = EpicsLocationType.all
    render :layout => false
  end

  def new
    @location_types = EpicsLocationType.new
  end

  def create
    @location_type = EpicsLocationType.new
    @location_type.name = params[:location_type][:name]
    @location_type.description = params[:location_type][:description]
    if @location_type.save!
       redirect_to :action => :index
    else
       redirect_to :action => :new
    end

  end

  def edit
    @location_type = EpicsLocationType.find(params[:location_type])
  end

  def update
    @location_type = EpicsLocationType.find(params[:location_type][:location_type_id])
    @location_type.name = params[:location_type][:name]
    @location_type.description = params[:location_type][:description]

    if @location_type.save!
       redirect_to :action => :index
    else
       redirect_to :action => :edit, :location_type_id => params[:location_type][:location_type_id]
    end
  end

  def void
    @location_type = EpicsLocationType.find(params[:location_type_id])
    @location_type.voided = 1
    @location_type.save!
		render :text => 'showMsg("Record Deleted!")'
  end
end
