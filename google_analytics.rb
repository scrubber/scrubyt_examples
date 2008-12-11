# google analytics scraper
#
# not trivial (besides the usual AJAX things) as the login form is in a frame
# as usual, replace asterisks with your username / pass

require 'rubygems'
require 'scrubyt'

data = Scrubyt::Extractor.define :agent => :firefox do
  fetch 'https://www.google.com/analytics/reporting/login'
  frame :name, "login"
  
  fill_textfield 'Email', '*****'
  fill_textfield 'Passwd', '*****'
  submit_and_wait 5
  
  pageviews "//div[@id='PageviewsSummary']//li[@class='item_value']", :example_type => :xpath
end

puts data.to_xml