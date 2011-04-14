class MaintenanceReportsController < ReportsController
				
				def new
								@report = MaintenanceReport.new(:staff_id => current_staff.id)
								session[:report] = @report
								respond_to do |format|
												format.html
								end
				end
				
				 # GET /incident_reports
  # GET /incident_reports.xml
  def index

  	@reports = MaintenanceReport.where(:submitted => true).order(:approach_time)

    
    respond_to do |format|
    	format.html { render :locals => { :reports => @reports } }
      format.xml  { render :xml => @reports }
      format.iphone {render :layout => 'mobile_application'}
    end
  end
  
  def edit
  				respond_to do |format|
  								format.html { render :text => "Edit of Maintenance Requests not supported. Shucks." }
  				end
  end
end
