class ContactController < ApplicationController

  def index
    @contacts = EpicsContact.all
    render :layout => "custom"
  end

  def new
    @contacts = EpicsContact.new
    @contact_title_map = ['Mr','Mrs','Ms','Dr','Prof']
  end

  def create
    @contact = EpicsContact.new
    @contact.title = params[:contact][:title]
    @contact.first_name = params[:contact][:first_name]
    @contact.last_name = params[:contact][:last_name]
    @contact.phone_number = params[:contact][:phone_number]
    @contact.email_address = params[:contact][:email_address]
    
    if @contact.save
      redirect_to :action => :index
    else
      redirect_to :action => :new
    end
  end

  def edit
    @contact = EpicsContact.find(params[:contact])
    @contact_title_map = ['Mr','Mrs','Ms','Dr','Prof']
  end

  def update
    @contact = EpicsContact.find(params[:contact][:contact_id])
    @contact.title = params[:contact][:title]
    @contact.first_name = params[:contact][:first_name]
    @contact.last_name = params[:contact][:last_name]
    @contact.phone_number = params[:contact][:phone_number]
    @contact.email_address = params[:contact][:email_address]

    if @contact.save
       redirect_to :action => :index
    else
       redirect_to :action => :edit, :contact_id => params[:contact][:epics_contact_id]
    end
  end

  def void
    @contact = EpicsContact.find(params[:contact_id])
    @contact.voided = 1
    @contact.save!
		render :text => 'showMsg("Record Deleted!")'
  end

  def send_email
    report = ReportController.new
    report.items_to_expire_next_six_months_to_pdf
    report.daily_dispensation_to_pdf
    report.daily_dispensation_to_pdf
    report.received_items_to_pdf
    EpicsContact.send_email
    render :text => "done" and return
  end

end
