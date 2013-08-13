
def start
  category_type = {}
  
  csv_url = "#{Rails.root}/script/drug_list/epics_drug_list.csv"
  FasterCSV.foreach("#{csv_url}", :quote_char => '"', :col_sep =>',', :row_sep =>:auto) do |line|
    drug_class = line[0].strip.split(' ')[0]
    col_one = (line[0].strip.split(' ')[1..-1].join(' ')).titleize
    col_two = line[1].strip.titleize rescue nil
    col_three = line[2].strip.titleize rescue nil
    col_four = line[3].strip.titleize rescue nil
    col_five = line[4].strip.titleize rescue nil
    col_six = line[5].strip.titleize rescue nil
    
    drug_name = col_one
    drug_name += col_two unless col_two.blank?
    drug_name += col_three unless col_three.blank?
    drug_name += col_four unless col_four.blank?
    drug_name += col_five unless col_five.blank?
    drug_name += col_six unless col_six.blank?
    category_type[drug_name] = drug_class
    puts "Class: #{drug_class} #{drug_name}" 
  end

  (category_type || {}).each do |drug_name, drug_class|
    EpicsProduct.transaction do
      cat_type = get_category_type(drug_class)
      unit = get_product_unit(drug_class)
      epics_product_type = get_epics_product_type(drug_class)
      next if cat_type.blank?
      product = EpicsProduct.new()
      product.product_code = drug_class
      product.name = drug_name
      product.expire = true
      product.min_stock = 1000
      product.max_stock = 10000
      product.movement = false
      product.epics_product_units_id = unit.id
      product.epics_product_category_id = cat_type.id
      product.epics_product_type_id = epics_product_type.id
      product.creator = 1
      product.save
      puts "created: #{drug_class}    #{drug_name}"
    end
  end

end

def get_epics_product_type(drug_class)
  drug_class = drug_class.first
  if drug_class.match(/A|B|C|E|/i)
    return EpicsProductType.where("name = 'Drugs'")[0]
  else
    return EpicsProductType.where("name = 'Sundries'")[0]
  end
end

def get_product_unit(drug_class)
  product_units = ["Each" , "Tablet","mg","KG","cm","Ltr","mL","Other"]
  case drug_class.first
    when 'A'
      return EpicsProductUnits.where("name = 'Tablet'")[0]
    when 'B' 
      return EpicsProductUnits.where("name = 'mL'")[0]
    when 'C'
      return EpicsProductUnits.where("name = 'mL'")[0]
    when 'D'
      return EpicsProductUnits.where("name = 'Each'")[0]
    when 'E'
      return EpicsProductUnits.where("name = 'Each'")[0]
    when 'F'
      return EpicsProductUnits.where("name = 'Each'")[0]
    when 'G'
      return EpicsProductUnits.where("name = 'Each'")[0]
    when 'H'
      return EpicsProductUnits.where("name = 'Each'")[0]
    when 'I'
      return EpicsProductUnits.where("name = 'Each'")[0]
    when 'K'
      return EpicsProductUnits.where("name = 'Each'")[0]
    when 'L'
      return EpicsProductUnits.where("name = 'Each'")[0]
    when 'M'
      return EpicsProductUnits.where("name = 'Each'")[0]
    when 'N'
      return EpicsProductUnits.where("name = 'Each'")[0]
    when 'P'
      return EpicsProductUnits.where("name = 'Each'")[0]
    when 'Q'
      return EpicsProductUnits.where("name = 'Each'")[0]
    else
      EpicsProductUnits.where("name = 'Other'")[0]
  end
end

def get_category_type(drug_class)
  EpicsProductCategory.where("name = ?","Class #{drug_class.first}")[0]
end

start
