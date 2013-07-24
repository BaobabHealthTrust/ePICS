class HomeController < ApplicationController
  def index
    @application = [
      ["Receive items","z","default.png"],
      ["Dispense","z","default.png"],
      ["Dispense","z","default.png"],
      ["View alerts","z","default.png"]
    ]

    @reports = []
    @activities = []
    @administration = [
      ["Add Item Units","z","default.png"],
      ["Add Items Types","z","default.png"],
      ["Add Item","z","default.png"],
      ["Add Supplier Type","z","default.png"],
      ["Add Supplier","z","default.png"],
      ["Add Order Type","z","default.png"],
    ]

    render :layout => false
  end

end
