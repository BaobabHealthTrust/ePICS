class HomeController < ApplicationController
  def index
    (session || {}).each do |name , values|
      next if name == 'location_name'
      next if name == 'location_id'
      next if name == 'user_id'
      session[name] = nil
    end

    @application = [
      ["Issue Items","orders/new","dispense.png"],
      ["Receive Items","stock/new","receive.png"],
      ["Exchange Items","epics_exchange/index","exchange_drugs1.png"],
      ["Lend Items","orders/lend","lend.png"],
      ["Borrow Items","stock/borrow","default.png"],
      ["Receive Loan Returns","/stock/receive_loan_returns","default.png"],
      ["Reimburse Borrowed Items","orders/return_loans","default.png"],
      ["Search","/product/search","search.png"]
    ]

    @reports = [
      ["Drug Availability","/report/select_store?report=drug_availability","available_drugs.png"],
      ["Daily Dispensation","/report/select_daily_dispensation_date","daily_dispense.png"],
      ["Central Hospital Monthly LMIS Report","/report/select_date_range","monthly_report.png"],
      ["Audit Report","#","audit_report.png"],
      ["View Received/Issued","#","view_issued_received.png"],
      ["View Store Room","/report/select_store","first_aid_kit_icon.png"],
      ["View alerts","/report/view_alerts","alert_list.png"]
    ]

    @activities = []

    @administration = [
      ["Set Items","/product/index","default.png"],
    ]

    if User.current.epics_user_role.name == "Administrator"
      @administration << ["Set Item Units","/product_units/index","units_icon.png"] << ["Set Item Types","/product_type/index","default.png"]
      @administration << ["Set Item Categories","/product_category/index","Item_categories.png"] << ["Set Order Types","/order_type/index","default.png"]
      @administration << ["Set Supplier Types","/supplier_type/index","default.png"] << ["Set Suppliers","/supplier/index","default.png"]
      @administration << ["Set Locations","/location/index","default.png"] << ["Set Location Types","/location_type/index","default.png"]
      @administration << ["Add New User","#","sysuser.png"] << ["Add person","person/add_person","add_user.png"]
    end

    @buttons_count = @application.length
    @buttons_count = @reports.length if @reports.length > @buttons_count
    @buttons_count = @activities.length if @activities.length > @buttons_count
    @buttons_count = @administration.length if @administration.length > @buttons_count

    ############################ alerts ######################################
    if params[:show_alerts_popup] == 'true'
      @alerts = EpicsReport.alerts
    end
    ################################ end #####################################

    render :layout => false
  end

end
