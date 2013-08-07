class HomeController < ApplicationController
  def index
    @application = [
      ["Receive Items","stock/new","default.png"],
      ["Issue Items","#","default.png"],
      ["Lend Items","#","default.png"],
      ["Exchange Items","#","default.png"],
      ["Search Items","#","default.png"]
    ]

    @reports = [["View Alerts","#","default.png"]]

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
    ]

    render :layout => false
    
  end

end
