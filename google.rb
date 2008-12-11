#The canonical google example

require 'rubygems'
require 'scrubyt'

google_data = Scrubyt::Extractor.define do
  fetch 'http://www.google.com/search?hl=en&q=ruby'
  
  link_title "//a[@class='l']", :write_text => true do
    link_url
  end
end

p google_data.to_hash
