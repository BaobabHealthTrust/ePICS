class UserController < ApplicationController
  def login


  end

  def logout
    reset_session
    redirect_to '/login'
  end

  def authenticate
    user = User.check_authenticity(params[:password], params[:login]) rescue nil
    if user.blank?
      flash[:error] = "Invalid user name or password"
      redirect_to '/login'
    else
      session[:user_id] = user.id
      if user.epics_user_role.blank?
        set_defualt_role(user.id)
      end
      redirect_to '/user/enter_workstation' and return
      redirect_to '/' and return
    end
  end

  def locations
    location = EpicsLocation.find_by_epics_location_id(params[:location]) rescue nil
    if location.blank?
      flash[:error] = "Invalid workstation location"
      redirect_to '/user/enter_workstation'
    else
      session[:location_name] = location.name
      session[:location_id] = location.id
      if location.epics_location_type.name == "Management"
         redirect_to root_path
      elsif EpicsLocationTag.find_by_location_id(location.id).blank?
          flash[:error] = "Unauthorised workstation location"
          redirect_to '/user/enter_workstation'
      else
        show_alerts_popup = false
        (EpicsReport.alerts || []).each do |name , count|
          if count > 0
            show_alerts_popup = true 
            break
          end 
        end
        
        redirect_to :controller => :home , :action => :index , 
          :show_alerts_popup => show_alerts_popup
      end
    end
  end

  def set_defualt_role(id)

    new_user_role = EpicsUserRole.new
    new_user_role.user_id = id
    new_user_role.epics_role_id = EpicsRole.find_by_role("Pharmacist").id
    new_user_role.save!

  end

  def new

    @roles = EpicsRole.all.map{|x| [x.role, x.id]}

  end

  def create

    if params[:password] != params[:password2]
      flash[:notice] = 'Password Mismatch'
      redirect_to :action => 'new'
    elsif (!User.find_by_username(params[:username]).blank?)
      flash[:notice] = 'Username already in use'
      redirect_to :action => 'new'
    else

      new_person = OpenmrsPerson.new
      new_person.creator = User.current.id
      new_person.save!
      new_name = OpenmrsPersonName.new
      new_name.person_id = new_person.id
      new_name.given_name = params[:fname]
      new_name.family_name = params[:lname]
      new_name.creator = User.current.id
      new_name.save!
      @user = User.new
      @user.person_id = new_person.id
      @user.username = params[:username]
      @user.password = params[:password]
      if @user.save

          role = EpicsUserRole.new
          role.user_id = @user.id
          role.epics_role_id = params[:role]
          role.save
          flash[:notice] = 'User successfully created'
          redirect_to :action=> 'summary', :user => @user.id
      else
        flash[:notice] = 'Failed to create new user'
        redirect_to :action=> 'new'
      end


    end
  end

  def summary
    @user = User.find(params[:user])
    render :layout => "custom"
  end

  def edit
    render :layout => "custom"
  end

end
