# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

puts 'loading location types'
location_types = [
  ["Facility","Other health centers"],
  ["Store room","Pharmacy store rooms"],
  ["Departments","Facility departments"],
  ["Medication Disposal","Pharmacy medication disposal"]
]

(location_types).each do |name , description|
  type = EpicsLocationType.new()
  type.name = name
  type.description = description
  type.save
end

puts 'loading locations'
locations = ["Tablets Stores","Injectable Stores","Surgical Stores"]
epics_location_type_id = EpicsLocationType.where("name = ?", location_types[1][0]).first.id
(locations).each do |name|
  type = EpicsLocation.new()
  type.name = name
  type.description = "Epics store location"
  type.epics_location_type_id = epics_location_type_id
  type.save

  tag = EpicsLocationTag.new()
  tag.location_id = type.id
  tag.save
end

epics_location = EpicsLocation.new
epics_location.epics_location_type_id = EpicsLocationType.find_by_name('Medication Disposal').id
epics_location.description = "Disposal of expired and damaged items"
epics_location.name = 'Incinerator'
epics_location.save!

puts 'loading lends or borrows types'
epics_lends_or_borrows_types = ["Borrow","Lend", "Donate"]

(epics_lends_or_borrows_types).each do |name|
  type = EpicsLendsOrBorrowsType.new()
  type.name = name
  type.description = "When the facility is : #{name}"
  type.save
end

puts 'loading order types'
order_types = ["Dispense","Exchange","Lend", "Return", "Board off", "Donate"]

(order_types).each do |name|
  type = EpicsOrderTypes.new()
  type.name = name
  type.description = "When: #{name} products"
  type.save
end

puts 'loading supplier types'
supplier_types = ["Government", "Donor", "Borrowed", "Private","Other"]

(supplier_types).each do |name|
  type = EpicsSupplierType.new()
  type.name = name
  type.description = "#{name}: provides pharmaceutical products"
  type.save
end

puts 'loading suppliers'
suppliers = [
  ["Central Medical Stores", supplier_types[0]],
  ["Other", supplier_types[4]]
]

(suppliers).each do |name, stype|
  type = EpicsSupplier.new()
  type.name = name
  type.local = 1
  type.epics_supplier_type_id = EpicsSupplierType.where("name = ?",stype)[0].id
  type.description = "#{name}: provides pharmaceutical products"
  type.save
end
puts 'loading item types'
item_types = ["Drugs" , "Sundries"]

(item_types).each do |name|
  type = EpicsProductType.new()
  type.name = name
  type.description = "When: #{name} products"
  type.save
end
puts 'loading item categories'
categories = [
  ['Class A','Tablets and Capsules'],
  ['Class B', 'Injectables'],
  ['Class C', 'Vaccines'],
  ['Class D', 'Raw Materials'],
  ['Class E', 'Galenicals'],
  ['Class F', 'Surgical dressings'],
  ['Class G', 'Sutures'],
  ['Class H', 'Surgical equipment'],
  ['Class I', 'Reading Glasses'],
  ['Class K', 'Dispensary items'],
  ['Class L', 'Hospital equipment'],
  ['Class M', 'Laboratory reagents and materials (Sundry)'],
  ['Class N', 'X-ray films and equipment'],
  ['Class P', 'Dental Items'],
  ['Class Q', 'Miscellaneous items'],
  ['TB programme drugs','TB programme drugs'],
  ['Family planning items and sexually transmitted infections’ items','Family planning items and sexually transmitted infections’ items'],
  ['Child lung health Programme Drugs','Child lung health Programme Drugs'],
  ['Global Fund items','Global Fund items']
]

(categories || []).each do |name, description|
  type = EpicsProductCategory.new()
  type.name = name
  type.description = description
  type.save
end

puts 'loading item units'
product_units = ["Each" , "Tablet","mg","KG","cm","Ltr","mL","Other"]

(product_units).each do |name|
  type = EpicsProductUnits.new()
  type.name = name
  type.description = "Unit of dispensing: #{name}"
  type.save
end

puts 'loading roles'
roles = [
         ["Administrator","overseer of all activities"], 
         ["Pharmacist", "receiver and issuer of items"],
         ['Pharmacy technician','receiver and issuer of items - works under Pharmacist']
        ]

(roles || []).each do |role, description|
  new_role = EpicsRole.new()
  new_role.role = role
  new_role.description = description
  new_role.save
end

puts 'loading items'
#`rails runner #{Rails.root}/script/load_epics_products.rb`
puts 'loading facilities'
`rails runner #{Rails.root}/script/load_epics_facilities.rb`
puts "Your new application is almost ready: make sure you configure your database.yml to point to your openmrs database for user management"
