class LocationController < ApplicationController
  def index
    @locations = EpicsLocation.all
    render :layout => "custom"
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
       if @location.epics_location_type.name.upcase == "STORE ROOM"
         tag = EpicsLocationTag.new()
         tag.location_id = @location.id
         tag.save
       end
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

  def search
    @names = EpicsLocation.where("name LIKE (?)","%#{params[:search_string]}%").collect do |location| 
      location.name
    end
    render :text => "<li>" + @names.map{|n| n } .join("</li><li>") + "</li>"
  end

  def print_location_menu
    store_room_id = EpicsLocationType.find_by_name('Store room').id
    store_locations = EpicsLocation.find_all_by_epics_location_type_id(store_room_id)
    @store_room_locations = store_locations.collect{|location|[location.name, location.id]}
  end
  
  def print_location
    location_id = params[:location_id]
    print_and_redirect("/location/location_label?location_id=#{location_id}", "/")
  end

  def location_label
		location_id = params[:location_id]
		print_string = get_location_label(EpicsLocation.find(location_id))
		send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{Time.now.to_i}.lbl", :disposition => "inline")
  end
  
  def get_location_label(location)
    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 2
    label.font_vertical_multiplier = 2
    label.left_margin = 50
    label.draw_barcode(50,180,0,1,5,15,120,false,"#{location.id}")
    label.draw_multi_text("#{location.name}")
    label.print(1)
  end
end
