class Report < ActiveRecord::Base
	belongs_to  	:staff
	belongs_to    :building
	has_one		    :annotation
	
  
  
  def update_attributes_without_saving(params)
    self.building_id = params[:building_id]
    self.room_number = params[:room_number]
    self.approach_time = params[:approach_time]   
  end
  
  
  
  
  def after_initialize
    if self.id == nil
      self.building_id = Building.unspecified
      self.approach_time = Time.now
      self.submitted = false
    end
  end
  
  
  
  
  def after_save
    # save each reported infraction to database
    self.reported_infractions.each do |ri|
      if !ri.frozen?                                # make sure the reported infraction isn't frozen
        ri.incident_report_id = self.id # establish connection
        ri.save                                     # actually save
      end
    end
  end
  
  
  
  
  def get_report_participant_relationships_for_participant(participant_id)
    found_relationships = Array.new
    self.reported_infractions.each do |ri|
      if ri.participant_id == participant_id
        found_relationships << ri
      end
    end
    return found_relationships
  end
  
  
  
  
  def get_specific_report_student_relationship(participant_id, relationship_id)
    self.reported_infractions.each do |ri|
      if ri.participant_id == participant_id && ri.infraction_id == relationship_id
        return ri
      end
    end
    return nil
  end
  
  
  
  
  def get_all_participants
    partic_relationships = Array.new
    
    # populate the old reported infractions array with the report's infractions
    self.reported_infractions.each do |ri|
      partic_relationships << ri
    end
    
    # sort the infractions so all infractions by same student are grouped
    partic_relationships.sort! { |a, b|  a.participant.last_name <=> b.participant.last_name } 
    
    #create array for the participants we have
    participants = Array.new
    
    # if we have more than one old reported infraction
    if partic_relationships.count > 0
      # search for unique participants and save ids
      curr_participant_id = partic_relationships.first.participant_id
      participants << curr_participant_id
      
      partic_relationships.each do |ri|
        if curr_participant_id != ri.participant_id
          curr_participant_id = ri.participant_id
          participants << curr_participant_id
        end
      end # end loop
    end # end if more than one old reported infraction
    
    return participants
  end
  
  
  
  
  def add_default_relationship_to_report_for_participant(participant_id)
    # only want to add if fyi doesn't already exist
    all_relationships_for_participant = get_report_participant_relationships_for_participant(participant_id)
    
    # only want to add if no relationships exist
    if all_relationships_for_participant.count == 0
      ri = ReportedInfraction.new(:participant_id => participant_id)
      self.reported_infractions << ri
      return ri
    else
      ri = get_specific_report_student_relationship(participant_id, Infraction.fyi) 
      return ri
    end
    
    
  end
  
  
  
  
  def add_specific_relationship_to_report_for_participant(participant_id, relationship_id)
    ri = get_specific_report_student_relationship(participant_id, relationship_id) 
    
    if ri == nil
      ri = ReportedInfraction.new(:participant_id => participant_id, :infraction_id => relationship_id)
      self.reported_infractions << ri
    end
    
    return ri
  end
  
  
  
  
  
  def add_default_report_student_relationships_for_participant_array(participants)    
    if participants != nil
      # go through the students and add fyi relationships
      participants.each do |s|
        add_default_relationship_to_report_for_participant(s.id)
      end
    end
  end
  
  
  
  
  
  def clear_session
    # clear everything out of the sesson
    session[:incident_report] = nil
    session[:annotation] = nil
    session[:students] = nil
  end
  
end


