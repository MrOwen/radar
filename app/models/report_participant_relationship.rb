class ReportParticipantRelationship < ActiveRecord::Base
	belongs_to :report
	belongs_to :participant
	belongs_to :relationship_to_report
  after_initialize :setup_defaults
  def self.table_name() "report_participants" end
  
  def setup_defaults
    if self.id == nil && self.relationship_to_report_id == nil
      self.relationship_to_report_id = RelationshipToReport.fyi
    end
  end
  
  def relationship_to_report
    if self.context != nil
        self.context.constantize.where(:id => self.relationship_to_report_id).first
    else
        #Need help
        self.relationship_to_report
    end
  end
  
end
