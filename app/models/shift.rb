class Shift < ActiveRecord::Base
  belongs_to :staff
  has_many :rounds, :dependent => :destroy
  belongs_to :area
  belongs_to :annotation, :dependent => :destroy
  has_many :task_assignments, :dependent => :destroy

  def update_attributes(params)
    self.annotation.text = params[:annotation]
    params[:annotation] = self.annotation
    super(params)
    # as in the controller, the following must be done to save the time in the correct time zone
    self.created_at = self.created_at.advance({:hours=>0})
    self.time_out = self.time_out.advance({:hours=>0})
    self.save
    # can't understand it
  end

  def assign_task (task)
    ta = TaskAssignment.new(:shift_id => self.id, :task_id => task.id, :done => false)
    self.task_assignments << ta
  end

  def annotation_text
    self.annotation.nil?  ? "" : (self.annotation.text.nil? ? "" :  self.annotation.text)
  end
  
  def save
    self.task_assignments.each do |ta|
      ta.save
    end
    self.annotation ||= Annotation.new
    self.annotation.save
    super
  end
  
  def tasks_completed? 
    TaskAssignment.where(:shift_id => self.id, :done => false).length == 0
  end
  
  def summary 
      self.annotation_text.length > 0 ?  self.annotation_text :  "No summary for this shift"
  end
  
  
  def start_time
    created_at.to_s(:time_only)
  end
  
  def start_date
    created_at.to_s(:short_date_only)
  end
  
  def end_time
    time_out.to_s(:time_only)
  end
  
  def end_date
    time_out.to_s(:short_date_only)
  end
  
  def Shift.sort(data,key)
    if key=="time_out"
      return data.order("shifts.time_out DESC")
    elsif key=="area"
      return data.joins(:area).order("areas.name ASC")
    elsif key=="submitter"
      return data.joins(:staff).order("staffs.last_name ASC")
    end
    return data.order("shifts.created_at DESC")
  end
  
end
