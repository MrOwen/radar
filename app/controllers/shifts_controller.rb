class ShiftsController < ApplicationController
  before_filter :authenticate_staff!
  skip_before_filter :verify_authenticity_token
  load_and_authorize_resource
  
  
  def index
    @shifts = Shift.sort(Shift,params[:sort])
    @numRows = 0
    
    respond_to do |format|
      format.html { render :locals => { :shifts => @shifts } }
      format.xml  { render :xml => @shifts }
    end
  end
  
  # GET /shifts/1
  # GET /shifts/1.xml
  def show
    respond_to do |format|
      
      format.html # show.html.erb
      format.xml  { render :xml => @shift }
    end
  end
  
  # GET /shifts/new
  # GET /shifts/new.xml
  def new
    # @shifts automatically loaded by CanCan
  end
  
  # GET /shifts/1/edit
  def edit
    # @shifts automatically loaded by CanCan
  end
  
  # POST /shifts
  # POST /shifts.xml
  def create
    respond_to do |format|
      if @shift.save
        format.html { redirect_to(@shift, :notice => 'Shift was successfully created.') }
        format.xml  { render :xml => @shift, :status => :created, :location => @shift }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shift.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /shifts/1
  # PUT /shifts/1.xml
  def update
    # @report_type automatically loaded by CanCan
  end
  
  # DELETE /shifts/1
  # DELETE /shifts/1.xml
  def destroy
    @shift.destroy
    
    respond_to do |format|
      format.html { redirect_to(shifts_url) }
      format.xml  { head :ok }
    end
  end
  
  def start_shift
    area_id = current_staff.staff_areas.first.area_id
    @shift = Shift.new(:staff_id => current_staff.id, :area_id => area_id)
    
    Task.get_active_by_area(area_id).each do |task|
      @shift.add_task(task) 
    end
    
    @shift.save
    
    respond_to do |format|
      format.js
    end
  end
  
  def duty_log
    @rounds = Round.where("shift_id = ?",params[:id]).order(:end_time)
    @task_assignments = TaskAssignment.where(:shift_id => @shift.id)

    report_map ||= Hash.new
    note_map ||= Hash.new
    round_time_start = @shift.created_at
    @rounds.each do |round|
      round_time_end=round.end_time
      reports = Report.where(:staff_id=>@shift.staff_id, :approach_time => round_time_start..round_time_end, :submitted=> true)
      notes = reports.where(:type=>"Note")
      notes = Report.sort(notes,params[:sort])
      reports = reports.where(:type=>["IncidentReport","MaintenanceReport"])
      reports = Report.sort(reports,params[:sort])
      report_map[round] = reports
      note_map[round] = notes
      round_time_start = round_time_end
    end
    
    respond_to do |format|
      format.html { render :locals => { :report_map => report_map, :note_map => note_map } }
      format.xml  { render :locals => { :report_map => report_map, :note_map => note_map } }
      format.js   { render :locals => { :report_map => report_map, :note_map => note_map } }
    end
  end
  
  def end_shift    
    @shift = Shift.where(:staff_id => current_staff.id, :time_out => nil).first
    if @shift == nil 
      return
    end
    @shift.time_out = Time.now
    @shift.save
    @round = Round.where(:end_time => nil, :shift_id => @shift.id).first
    if @round != nil	    	
      @round.end_time = Time.now
      @round.save
      @notice = "You are now off a round and off duty."
    else
      @notice = "You are now off duty."		
    end
	
    if !@shift.tasks_completed?
      @notice = @notice + "...but some tasks were not completed!"
    end
    
    respond_to do |format|
      format.js 
    end
  end
  
  def update_todo
    task_list = params[:task]
    TaskAssignment.where(:shift_id => current_staff.current_shift.id).each do | assignment |
      assignment.done = task_list[assignment.id.to_s] != nil
      assignment.save
    end
  
    respond_to do |format|
      format.iphone { render :nothing => true }
    end
  end
  
end
