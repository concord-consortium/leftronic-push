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
portals = {
  General: {
    url: "http://admin.concord.org/portalstats/"
  },
  CODAP: {
    url: "http://codap.portal.concord.org/misc/stats.json"
  },
  Genigames: {
    # FIXME Need to find numbers...
    data: {
      active_classes: 0,
      active_teachers: 0,
      active_students: 0,
      active_runnables: 0,
      teachers: 0,
      students: 0,
      classes: 0
    }
  },
  Geniverse: {
    url: "http://geniverse.concord.org/portal/misc/stats.json",
    data: {
      active_classes: 1396,
      active_teachers: 1101,
      active_students: 20800,
      active_runnables: 1396,
      teachers: 1101,
      students: 20800,
      classes: 1396
    }
  },
  HAS: {
    url: "http://has.portal.concord.org/misc/stats.json"
  },
  InquirySpace: {
    # AU 2015-10-23: Dan wasn't sure on numbers, but didn't think there were a significant amount... Trudi supplied a gut-level estimate.
    url: "http://inquiryspace.portal.concord.org/misc/stats.json",
    data: {
      active_classes: 25,
      active_teachers: 10,
      active_students: 500,
      active_runnables: 100,
      teachers: 10,
      students: 500,
      classes: 25
    }
  },
  Interactions: {
    url: "http://interactions.portal.concord.org/misc/stats.json"
  },
  RITES: {
    url: "http://investigate.ritesproject.net/misc/stats.json"
  },
  ITSI: {
    # This is data from before ITSI was merged into the Learn portal. Teacher accounts were migrated, though,
    # so we're leaving 'teachers' at 0 so we don't double-count. Classes and students weren't migrated, so
    # we're still counting 'active_teachers'
    url: "http://itsi-portal-2009.concord.org/misc/stats.json",
    data: {
      active_classes: 1129,
      active_teachers: 407,
      active_students: 18440,
      active_runnables: 647,
      teachers: 0,
      students: 34898,
      classes: 3910
    }
  },
  Learn: {
    url: "https://learn.concord.org/misc/stats.json"
  },
  NGSS: {
    url: "http://ngss-assessment.portal.concord.org/misc/stats.json"
  }
}
portal_stats = portals.map{|portal, config|
  data = {}
  if config[:data]
    data = config[:data]
  elsif config[:url]
    puts "Getting stats from: #{portal} (#{config[:url]})"
    begin
      data = JSON.parse(open(config[:url]).read)
    rescue => e
      puts "FAILED!\n#{e}"
    end
  end
  data
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
