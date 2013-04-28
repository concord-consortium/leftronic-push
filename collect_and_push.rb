# push some data into leftronic
require 'leftronic'
require 'json'
require 'open-uri'

metrics = {
  classes: 0,
  teachers: 0,
  students: 0,
  runnables: 0,
  total_teachers: 0,
  total_students: 0,
  total_classes: 0
}

###
# pull data from portals
###
portals = [
  "investigate.ritesproject.net",
  "has.portal.concord.org",
  "itsisu.portal.concord.org",
  "interactions.portal.concord.org"
]
portal_stats = portals.map{|portal|
  puts "Getting stats from: #{portal}"
  JSON.parse(open("http://#{portal}/misc/stats.json").read)
}

portal_stats.each{|stat|
  metrics[:classes] += stat["active_classes"].to_i if stat["active_classes"]
  metrics[:teachers] += stat["active_teachers"].to_i if stat["active_teachers"]
  metrics[:students] += stat["active_students"].to_i if stat["active_students"]
  metrics[:runnables] += stat["active_runnables"].to_i if stat["active_runnables"]
  metrics[:total_teachers] += stat["teachers"].to_i if stat["teachers"]
  metrics[:total_students] += stat["students"].to_i if stat["students"]
  metrics[:total_classes] += stat["classes"].to_i if stat["classes"]
}

### 
# add in static stats from php portal:
###

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
metrics[:classes] += 2290
metrics[:teachers] += 819
metrics[:students] += 44314

# select member_type, count(*) from portal_members group by member_type;
# +-------------+----------+
# | member_type | count(*) |
# +-------------+----------+
# | admin       |     2604 | 
# | student     |    53523 | 
# | superuser   |       19 | 
# | teacher     |     1293 | 
# +-------------+----------+
metrics[:total_teachers] += 1293
metrics[:total_students] += 53523

# select count(*) from portal_classes;
metrics[:total_classes] += 4125

# from activity finder
metrics[:runnables] += 87
# from php portal
# ???

puts metrics.inspect

update = ENV['LEFTRONIC_KEY'] ? Leftronic.new(ENV['LEFTRONIC_KEY']) : nil

metrics.each{|key, value|
  if update
    update.push_number key.to_s, value
  else
    puts "#{key.to_s}: #{value}"
  end
}
