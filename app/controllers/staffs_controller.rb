class StaffsController < Devise::RegistrationsController
  # GET /staffs
  # GET /staffs.xml
  before_filter :authenticate_staff!
  before_filter :super_admin_authorize_view_access
  
  def index
    @staffs = Staff.all
    @numRows = 0
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @staffs }
    end
  end

  # GET /staffs/1
  # GET /staffs/1.xml
  def show
    @staff = Staff.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @staff }
    end
  end
  
  def edit
    @staff = Staff.find(params[:id])
  end

  # GET /staffs/new
  # GET /staffs/new.xml
  def new_old
    @staff = Staff.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @staff }
      format.iphone {render :layout => 'mobile_application'}
    end
  end


  # DELETE /staffs/1
  # DELETE /staffs/1.xml
  def destroy
    @staff = Staff.find(params[:id])
    @staff.destroy

    respond_to do |format|
      format.html { redirect_to(staffs_url) }
      format.xml  { head :ok }
    end
  end
  def update
    @staff = Staff.find(params[:id])
    
    respond_to do |format|
      if @staff.update_attributes(params[:staff])
        format.html { redirect_to(@staff, :notice => 'Staff was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @staff.errors, :status => :unprocessable_entity }
      end
    end
   end
end
