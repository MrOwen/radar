class AnnotationsController < ApplicationController
  before_filter :authenticate_staff!
  load_and_authorize_resource

  # GET /annotations
  # GET /annotations.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @annotations }
    end
  end

  # GET /annotations/1
  # GET /annotations/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @annotation }
    end
  end

  # GET /annotations/new
  # GET /annotations/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @annotation }
    end
  end

  # GET /annotations/1/edit
  def edit
  end

  # POST /annotations
  # POST /annotations.xml
  def create
    respond_to do |format|
      if @annotation.save
        format.html { redirect_to(@annotation, :notice => 'Annotation was successfully created.') }
        format.xml  { render :xml => @annotation, :status => :created, :location => @annotation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @annotation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /annotations/1
  # PUT /annotations/1.xml
  def update
    respond_to do |format|
      if @annotation.update_attributes(params[:annotation])
        format.html { redirect_to(@annotation, :notice => 'Annotation was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @annotation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /annotations/1
  # DELETE /annotations/1.xml
  def destroy
    @annotation.destroy

    respond_to do |format|
      format.html { redirect_to(annotations_url) }
      format.xml  { head :ok }
    end
  end
end
