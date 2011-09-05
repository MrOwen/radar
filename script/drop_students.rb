load 'ar_support.rb'

lines = ImportsHelper.parse_csv_file(File.expand_path("./shradarwdraw.csv"))
lines.shift
print "Process #{lines.size} drop records"
scnt = ImportsHelper.deactivate_students(lines)
puts "Successfully dropped #{scnt} students. #{lines.size-scnt} failures."
puts ImportsHelper::Helpers.stats
puts "ERROR MESSAGES:"
puts ImportsHelper::Helpers.error_messages