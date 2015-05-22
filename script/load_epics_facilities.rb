
def load_facilities
	facilities = []
	csv_url = "#{Rails.root}/script/facilities/facilities.csv"
	facility_type = EpicsLocationType.where(:name => "facility")[0]

	CSV.foreach("#{csv_url}",:quote_char => '"', :col_sep =>',', :row_sep =>:auto) do |facility|
		
		new_location = EpicsLocation.new()
		new_location.name = facility[0].to_s
		new_location.epics_location_type_id = facility_type.id
		new_location.description = "Other facilities"
		new_location.save!
	end
end

load_facilities
