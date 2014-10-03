
def start
  csv_url = "#{Rails.root}/doc/list.csv"
  csv_url2 = "#{Rails.root}/doc/missing.csv"
  csv_url3 = "#{Rails.root}/doc/misclassified.csv"
  non_existent = []
  misplaced = []
  exist = []

  FasterCSV.foreach("#{csv_url}", :quote_char => '"', :col_sep =>',', :row_sep =>:auto) do |line|
    code = line[0].squish rescue nil
    drug_name = line[2].squish rescue nil


    next if code.blank? || drug_name.blank?

    code_drug = EpicsProduct.find_by_product_code(code)
    name_drug = EpicsProduct.find_by_name(drug_name)
    if (code_drug.blank? && name_drug.blank?)
      non_existent << [code, drug_name]
    elsif (code_drug.blank? && !name_drug.blank?)
        misplaced << [code,name_drug.product_code, drug_name, name_drug.name, "Wrong Code for drug"]
    elsif (!code_drug.blank? && name_drug.blank?)
        misplaced << [code,code_drug.product_code, drug_name, code_drug.name, "Wrong drug for code"]
    else
      exist << code
    end

  end


  FasterCSV.open("#{csv_url2}", "wb") do |csv|
    csv << ["Code", "Name"]

    (non_existent || []).each do |drug|

      csv << [drug[0], drug[1]]
    end

  end

  FasterCSV.open("#{csv_url3}", "wb") do |csv|
    csv << ["Actual Code", "Current Code","Name", "Old Names", "Reason"]

    (misplaced || []).each do |drug|

      csv << [drug[0], drug[1], drug[2], drug[3], drug[4]]
    end

  end

  puts "Available Drugs : #{exist.length}"
  puts "Missing Drugs : #{non_existent.length}"
  puts "Misplaced Drugs : #{misplaced.length}"

end

start
