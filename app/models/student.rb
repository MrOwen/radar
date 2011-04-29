class Student < Participant
	belongs_to :building
	
	#self.view_name = "participant_view" 
	
	def initialize(newId) 
		@id = newId
	end
	
	def full_name
		"#{self.first_name} #{self.last_name}, #{self.building.abbreviation}, #{self.room_number}"
		end
	def get_id
		"#{:id}"
	end
end
