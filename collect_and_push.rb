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
  "admin.concord.org/portalstats/",
  "codap.portal.concord.org/misc/stats.json",
  "geniverse.concord.org/portal/misc/stats.json",
  "has.portal.concord.org/misc/stats.json",
  "inquiryspace.portal.concord.org/misc/stats.json",
  "interactions.portal.concord.org/misc/stats.json",
  "investigate.ritesproject.net/misc/stats.json",
  "itsi.portal.concord.org/misc/stats.json",
  "learn.concord.org/misc/stats.json",
  "ngss-assessment.portal.concord.org/misc/stats.json"
]
portal_stats = portals.map{|portal|
  puts "Getting stats from: #{portal}"
  JSON.parse(open("http://#{portal}").read)
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


# Adding static stats from activity finder:
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
