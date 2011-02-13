class Report < ActiveRecord::Base
	belongs_to  	:submitter, :class_name => "Staff"
	belongs_to     	:building
	has_many	:annotations
end

