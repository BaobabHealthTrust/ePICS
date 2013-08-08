class HomeController < ApplicationController
  def index
    @application = [
      ["Issue Items","orders/new","default.png"],
      ["Receive Items","stock/new","default.png"],
      ["Exchange Items","epics_exchange/index","default.png"],
      ["Lend Items","orders/lend","default.png"],
      ["Update Items","#","default.png"],
      ["Search","/product/search","default.png"]
    ]

    @reports = [
      ["Drug Availability","/report/drug_availability","default.png"],
      ["Daily Dispensation","/report/daily_dispensation","default.png"],
      ["Central Hospital Monthly LMIS Report","/report/monthly_report","default.png"],
      ["Audit Report","/report/audit_report","default.png"],
      ["View Received/Issued","/report/received_items","default.png"],
      ["View Store Room","/report/store_room","default.png"],
      ["View alerts","/report/view_alerts","default.png"]
    ]
    @activities = []
    @administration = [
      ["Set Item Units","/product_units/index","default.png"],
      ["Set Item Types","/product_type/index","default.png"],
      ["Set Item Categories","/product_category/index","default.png"],
      ["Set Items","/product/index","default.png"],
      ["Set Supplier Types","/supplier_type/index","default.png"],
      ["Set Suppliers","/supplier/index","default.png"],
      ["Set Order Types","/order_type/index","default.png"],
      ["Set Location Types","/location_type/index","default.png"],
      ["Set Locations","/location/index","default.png"],
      ["Add person","person/add_person","default.png"],
    ]

    @buttons_count = @application.length
    @buttons_count = @reports.length if @reports.length > @buttons_count
    @buttons_count = @activities.length if @activities.length > @buttons_count
    @buttons_count = @administration.length if @administration.length > @buttons_count

    render :layout => false
    
  end

end
