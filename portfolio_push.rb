#!/usr/bin/env ruby

# Consume CSV from a Google Spreadsheet
# Arrange data and push to Leftronics

require 'csv'
require 'httparty'
require 'leftronic'

# The widget we're pushing to 
LEFTRONICS_STREAM_NAME = 'ghZl9bRC'
# Data source
# Actual:
GOOGLE_SPREADSHEET_URL = 'https://docs.google.com/spreadsheet/pub?key=0AjOPw2voB45PdE0zdUlUc1lhRWg3RmYwZEFGQWIxdnc&single=true&gid=10&output=csv'

# Hardwiring this project list is brittle.
@projects = [
  { :abbr => "RT", :name => "RITES", :devs => [] },
  { :abbr => "CL", :name => "CLEAR", :devs => [] },
  { :abbr => "SP", :name => "SPARKS", :devs => [] },
  { :abbr => "SG", :name => "SmartGraphs", :devs => [] },
  { :abbr => "IS", :name => "ITSI-SU", :devs => [] },
  { :abbr => "GV", :name => "Geniverse", :devs => [] },
  { :abbr => "CC", :name => "CC Collection", :devs => [] },
  { :abbr => "SF", :name => "SFF Activity", :devs => [] },
  { :abbr => "GG", :name => "GeniGames", :devs => [] },
  { :abbr => "GL", :name => "MW NextGen", :devs => [] },
  { :abbr => "MI", :name => "MSU Interactions", :devs => [] },
  { :abbr => "IQ", :name => "InquirySpace", :devs => [] },
  { :abbr => "HS", :name => "HAS: ESS", :devs => [] },
  { :abbr => "SS", :name => "Sensing Science", :devs => [] },
  { :abbr => "GI", :name => "Geniville", :devs => [] },
  { :abbr => "ME", :name => "ME Graph Lit", :devs => [] },
  { :abbr => "IN", :name => "Intel Learning Series", :devs => [] },
  { :abbr => "TD", :name => "Technical Debt", :devs => [] },
  { :abbr => "Va", :name => "Vacation", :devs => [] },
  { :abbr => "Am", :name => "Administration", :devs => [] },
  { :abbr => "CM", :name => "Cloud migration", :devs => [] },
  { :abbr => "UP", :name => "Unified Portal", :devs => [] }
]

# Get the data
class DataSource
  include HTTParty
  format :plain
end

# Array of values
spreadsheet = DataSource.get(GOOGLE_SPREADSHEET_URL)
lines = CSV.parse(spreadsheet)

lines.each do |d|
  unless d[0].nil?
    @dev = d[0]
  end
  proj = @projects.select {|p| p[:abbr] == d[1] }
  unless proj.nil? or proj.empty?
    proj[0][:devs] << @dev
  end
end

portfolio_list = []
@projects.each do |p|
  # For projects with a dev assigned...
  unless p[:devs].empty?
    portfolio_list << "#{p[:name]}: #{p[:devs].join(', ')}"
  end
end

# See https://www.leftronic.com/api/#ruby
update = Leftronic.new ENV['LEFTRONIC_KEY']
update.list LEFTRONICS_STREAM_NAME, portfolio_list

# done