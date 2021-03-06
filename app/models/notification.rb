class Notification

  def Notification.never
    0
  end

  def Notification.immediate
    1
  end

  def Notification.daily
    2
  end

  def Notification.weekly
    3
  end

  def Notification.building_only
    0
  end

  def Notification.area_only
    1
  end

  def Notification.all_areas
    2
  end

  def Notification.get_time_offset_for_frequency(f)
    if(f > immediate)
			return 360
		end
    if(f < daily)
			return -1
    end
  end

	def Notification.immediate_notify(id)
		notify_prefs = Array.new
		
		report = Report.find(id)

		notify_prefs = NotificationPreference.where(:frequency => immediate, :report_type => report.type).all
		notify_prefs.each do |np|
			to_staff = Staff.find(np.staff_id) 
			ok_to_send = (not to_staff.nil?) && to_staff.active
			begin
				RadarMailer.notification_mail({report.display_name => [report]}, to_staff).deliver if ok_to_send 
			rescue 
			end
		end	
	end
	
	def Notification.notify
		plist = Array.new
		prefs = NotificationPreference.all(:select => 'distinct(staff_id)')
		
		prefs.each do |pref|
			reports = Hash.new
			plist = NotificationPreference.where(:staff_id => pref.staff_id, :frequency =>(daily..weekly))
			notify = false
			plist.each do |p|
				notify = Notification.should_notify(p)
				if notify
					r = Report.where(:created_at => (p.last_notified..Time.now), :type => p.report_type)
					if r.first != nil
						temp_hash = {r.first.display_name => r}
						reports.merge!(temp_hash)
					end
					p.last_notified = Time.now
					p.save
				end
			end
			to_staff = Staff.find(pref.staff_id)
			if notify and (not to_staff.nil?) and to_staff.active
				mail = RadarMailer.notification_mail(reports, to_staff)
				mail.deliver
			end
		end
	end
	
	def Notification.should_notify(preference)
		if preference.frequency == weekly
			base_time = Time.now.beginning_of_week
		else 
			base_time = Time.now.beginning_of_day
		end
		t = preference.time_offset*60
		mm, ss = t.divmod(60)
		hh, mm = mm.divmod(60)
		dd, hh = hh.divmod(24)
		request_time = base_time + dd.day + hh.hour + mm.minutes + ss.seconds
		if preference.last_notified == nil
			last_notify = Time.new(1970)
			preference.last_notified = Time.new(1970)
			preference.save
		else
			last_notify = preference.last_notified
		end
		#puts last_notify
		#puts preference.last_notified
		#puts request_time
		#puts Time.now
		return (last_notify < request_time and request_time <= Time.now)
	
	end
end