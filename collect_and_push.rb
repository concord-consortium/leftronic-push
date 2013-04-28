# push some data into leftronic
require 'leftronic'
require 'json'
require 'open-uri'

# pull data from portals
portals = [
  "investigate.ritesproject.net",
  "has.portal.concord.org",
  "itsisu.portal.concord.org",
  "interactions.portal.concord.org"
]
stats = portals.map{|portal|
  puts "Getting stats from: #{portal}"
  JSON.parse(open("http://#{portal}/misc/stats.json").read)
}

classes = 0
teachers = 0
students = 0
runnables = 0
total_teachers = 0
total_students = 0
total_classes = 0
stats.each{|stat|
  classes += stat["active_classes"].to_i if stat["active_classes"]
  teachers += stat["active_teachers"].to_i if stat["active_teachers"]
  students += stat["active_students"].to_i if stat["active_students"]
  runnables += stat["active_runnables"].to_i if stat["active_runnables"]
  total_teachers += stat["teachers"].to_i if stat["teachers"]
  total_students += stat["students"].to_i if stat["students"]
  total_classes += stat["classes"].to_i if stat["classes"]
}

# add in static stats from php portal:
# select count(distinct portal_class_students.class_student_id) as active_students, 
# count(distinct portal_classes.class_id) as active_classes, 
# count(distinct portal_classes.class_teacher) as active_teachers from portal_classes 
# inner join portal_class_activities on portal_classes.class_id = portal_class_activities.class_id 
# inner join portal_class_students on portal_class_students.class_id = portal_classes.class_id 
# inner join portal_members on portal_members.member_id = portal_classes.class_teacher;
# +-----------------+----------------+-----------------+
# | active_students | active_classes | active_teachers |
# +-----------------+----------------+-----------------+
# |           44314 |           2290 |             819 |
# +-----------------+----------------+-----------------+

teachers += 819
students += 44314
classes += 2290

# select member_type, count(*) from portal_members group by member_type;
# +-------------+----------+
# | member_type | count(*) |
# +-------------+----------+
# | admin       |     2604 | 
# | student     |    53523 | 
# | superuser   |       19 | 
# | teacher     |     1293 | 
# +-------------+----------+
total_teachers += 1293
total_students += 53523

# select count(*) from portal_classes;
total_classes += 4125

# from activity finder
runnables += 87
# from php portal
# ???

puts "active -- classes: #{classes}, teachers: #{teachers}, students: #{students}, runnables: #{runnables}"
puts "total  -- classes: #{total_classes}, teachers: #{total_teachers}, students: #{total_students}"

update = Leftronic.new ENV['LEFTRONIC_KEY']

update.push_number "classes", classes
update.push_number "teachers", teachers
update.push_number "students", students
update.push_number "runnables", runnables
update.push_number "total_classes", total_classes
update.push_number "total_teachers", total_teachers
update.push_number "total_students", total_students


# hard to find page about splunkstorm api
# http://help.splunkstorm.com/kb/for-developers/api-documentation
# splunk API KEY:
# PJ70hkL2BHlWyzopX-0Pl0aXEQmRwMHsCQryr0F2EcgbR2iRn9sUVcFzeLiGyejpljCxfFhVPNY=
# log of json export of results through UI:
# https://search7.splunkstorm.com/en-US/api/search/jobs/
#   bf99cd3a21e911e295d222000a1cdcf0__bf99cd3a21e911e295d222000a1cdcf0__bfab78dc21e911e295d222000a1cdcf0__RMD523cfcede34a3496f_1351567220.4318/
#     result?isDownload=true&timeFormat=%25FT%25T.%25Q%25%3Az&maxLines=0&count=10&filename=Top10Activities&outputMode=json&spl_ctrl-limit=limit&spl_ctrl-count=10

# my guess for retrieving results of an existing search:
# https://search7.splunkstorm.com/en-US/api/search/jobs/
#   bf99cd3a21e911e295d222000a1cdcf0__bf99cd3a21e911e295d222000a1cdcf0__bfab78dc21e911e295d222000a1cdcf0__RMD523cfcede34a3496f_1351567220.4318/
#     result?timeFormat=%25FT%25T.%25Q%25%3Az&count=10&&outputMode=json
# 
# https://search7.splunkstorm.com/en-US/api/search/jobs/bf99cd3a21e911e295d222000a1cdcf0__bf99cd3a21e911e295d222000a1cdcf0__bfab78dc21e911e295d222000a1cdcf0__RMD523cfcede34a3496f_1351567220.4318/result?timeFormat=%25FT%25T.%25Q%25%3Az&count=10&&outputMode=json

# bf99cd3a21e911e295d222000a1cdcf0__bf99cd3a21e911e295d222000a1cdcf0__bfab78dc21e911e295d222000a1cdcf0__RMD523cfcede34a3496f_1351567220.4318
# bf99cd3a21e911e295d222000a1cdcf0__bf99cd3a21e911e295d222000a1cdcf0__bfab78dc21e911e295d222000a1cdcf0__RMD523cfcede34a3496f_1351629284.5676
# bfab78dc21e911e295d222000a1cdcf0