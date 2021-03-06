class HomeController < ApplicationController

  
  def landingpage
    if staff_signed_in?
      @unsubmitted = Report.accessible_by(current_ability).where(:submitted => false, :staff_id => current_staff.id).preferred_reports(current_staff)
      @unsubmitted = @unsubmitted.preferred_order(current_staff)
      @recent = Report.accessible_by(current_ability).where(:created_at => (current_staff.last_sign_in_at)..(Time.now), :submitted => true).preferred_reports(current_staff)
      @recent = @recent.preferred_order(current_staff)
    end
  
    respond_to do |format|
      format.html
      format.xml
      format.iphone {render :layout => 'mobile_application'}
      format.js
    end
  end
  
end