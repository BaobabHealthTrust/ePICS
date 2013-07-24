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
    @admin = []

    render :layout => false
  end

end
