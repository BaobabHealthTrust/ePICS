class PersonController < ApplicationController
  def add_person

  end

  def get_name

    render :text => EpicsPerson.get_name(params[:search_string])

  end

  def new_person

    person = EpicsPerson.new
    person.fname = params[:fname]
    person.lname = params[:lname]
    person.has_authority = params[:authority].eql?('Yes') ? true : false
    person.save
    redirect_to '/'
  end

end
