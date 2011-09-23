class Staff < ActiveRecord::Base
  has_many :staff_organizations, :dependent => :destroy
  has_many :staff_areas, :dependent => :destroy
  belongs_to :access_level
  belongs_to :area

  belongs_to :organization
  has_many :notification_preferences
  before_save :lower_email
  after_initialize :set_active
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :timeoutable
  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :area, :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :access_level_id, :active, :staff_areas, :staff_organizations

 
  def name
    first_name + " " + last_name
  end
  
  def last_name_first_initial
    last_name + ( ", #{first_name[0]}" rescue "")
  end
  
  def last_login
	self.last_sign_in_at
  end
  # return true is I have seen given report
  def has_seen? (report)
   ReportViewLog.find_by_staff_id_and_report_id(self.id, report.id) != nil
  end
  
  def areas
    Area.joins(:staff_areas).where("staff_id = ?", self.id)
  end
  
  def adjuncts
	Staff.joins(:staff_areas).where('staff_areas.area_id' =>  areas.collect { |a| a.id } ).where("staff_areas.staff_id != ?", self.id)
  end
  
  def devise_creation_param_handler(params)
  logger.debug("*******devise_creation_param_handler: staff_id = #{self.id} ")
   # params[:staff_areas] = [ StaffArea.new(:staff_id => self.id, :area_id => params[:staff_areas]) ]
   # params[:staff_organizations] = [ StaffOrganization.new(:staff_id => self.id, :organization_id => params[:staff_organizations]) ]
	params[:staff_areas] = [ StaffArea.new( :area_id => params[:staff_areas]) ]
    params[:staff_organizations] = [ StaffOrganization.new( :organization_id => params[:staff_organizations]) ]
  end

  def get_registerable_access_levels

    res_life_level =  AccessLevel.find_by_name('ResidentAssistant').numeric_level
    sys_admin_level = AccessLevel.find_by_name('SystemAdministrator').numeric_level

    if self.access_level.numeric_level > res_life_level && self.access_level.numeric_level <  sys_admin_level
      #can only register access levels below current level
      level_array =  res_life_level..(self.access_level.numeric_level-1)
      return AccessLevel.where(:numeric_level => level_array)
    elsif self.access_level.numeric_level ==  sys_admin_level
      #system admins can make other system admins
      level_array =  res_life_level..self.access_level.numeric_level
      return AccessLevel.where(:numeric_level => level_array)
    else
      #if level 1, can register as level 1 (only to be used when updating self)
      return AccessLevel.where(:numeric_level => self.access_level.numeric_level)
    end
  end

  def access_level?(access_level)
    if self.access_level == nil
      return false
    end

    return self.access_level.name == access_level.to_s.camelize
  end

  def sign_out_confirmation
    confirmation = ""
    if self.on_duty?
      confirmation += "You are still on duty"

      if self.on_round?
        confirmation += " and on a round"
      end
      confirmation += "!\n\n"
    end
    return confirmation + "Are you sure you want to sign out?"
  end

  def get_registerable_organizations
    reg_org_ids = Array.new
    self.staff_organizations.each do |staff_org|
      reg_org_ids << staff_org.organization.id
    end
    
    return Organization.where(:id=>reg_org_ids).order(:name)
  end

  def organization?(organization)
    if self.staff_organizations.first == nil
      return false
    end
    
    return self.staff_organizations.first.organization.name == organization.to_s.camelize
  end

  def lower_email
    self.email = email.downcase
  end
  
  def on_duty?
    current_shift != nil
  end
  
  def on_round?
    (Round.where(:shift_id => current_shift.id, :end_time => nil).first != nil) rescue false
  end
  

  
  def set_active
    self.active = true
  end
  
  
  def current_shift
    Shift.where(:staff_id => self.id, :time_out => nil).first
  end

  def current_round
    Round.where(:end_time => nil, :shift_id => self.current_shift.id).first
  end
  
  def currently_assigned_tasks
    if (current_shift == nil)
	  return []
	end
    anytime = -1
    timed_assignments = TaskAssignment.joins(:task).where( "shift_id = ? AND tasks.time > ?", self.current_shift.id, anytime ).order(:time).all
    untimed_assignments = TaskAssignment.joins(:task).where( :shift_id => self.current_shift.id, :tasks => {:time => anytime }).all
    timed_assignments ||= []
    untimed_assignments ||= []
    return timed_assignments + untimed_assignments
  end
  
  def update_attributes(staff)
    if staff[:staff_organizations] != nil
      so = StaffOrganization.where(:staff_id => self.id).first
      so.organization_id = staff[:staff_organizations]
      so.save
      staff[:staff_organizations] = [so]
    end
    if staff[:staff_areas] != nil
      sa = StaffArea.where(:staff_id => self.id).first
      sa.area_id = staff[:staff_areas]
      sa.save
      staff[:staff_areas] = [sa]
    end
    
    super(staff)
  end
  
end
