class ReportTypesController < ApplicationController
  # GET /report_types
  # GET /report_types.xml
  before_filter :authenticate_staff!
  before_filter :super_admin_authorize_view_access
  
  
  def index
    @report_types = ReportType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @report_types }
    end
  end

  # GET /report_types/1
  # GET /report_types/1.xml
  def show
    @report_type = ReportType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @report_type }
    end
  end

  # GET /report_types/new
  # GET /report_types/new.xml
  def new
    @report_type = ReportType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @report_type }
    end
  end

  # GET /report_types/1/edit
  def edit
    @report_type = ReportType.find(params[:id])
  end

  # POST /report_types
  # POST /report_types.xml
  def create
    @report_type = ReportType.new(params[:report_type])

    respond_to do |format|
      if @report_type.save
        format.html { redirect_to(@report_type, :notice => 'Report type was successfully created.') }
        format.xml  { render :xml => @report_type, :status => :created, :location => @report_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @report_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /report_types/1
  # PUT /report_types/1.xml
  def update
    @report_type = ReportType.find(params[:id])

    respond_to do |format|
      if @report_type.update_attributes(params[:report_type])
        format.html { redirect_to(@report_type, :notice => 'Report type was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @report_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /report_types/1
  # DELETE /report_types/1.xml
  def destroy
    @report_type = ReportType.find(params[:id])
    @report_type.destroy

    respond_to do |format|
      format.html { redirect_to(report_types_url) }
      format.xml  { head :ok }
    end
  end
end
