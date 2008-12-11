# Yahoo suggestions scraping
#
# Not trivial as the suggestions are dynamically loaded into a popup
require 'rubygems'
require 'scrubyt'
require 'cgi'

Scrubyt.logger = Scrubyt::Logger.new


yahoo_data = Scrubyt::Extractor.define :agent => :firefox do
  fetch 'http://www.yahoo.com' 
  fill_textfield_and_wait 'p', 'ruby', 5
  
  suggestion_list "//div[@id='ac_container']//li/a", :example_type => :xpath do
    href "href", :type => :attribute do
      escaped_string /&p=(.+?)$/ do
        suggestion lambda {|x| CGI::unescape(x)}, :type => :script
      end
    end
  end
end

p yahoo_data.to_hash

