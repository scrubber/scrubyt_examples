#simple ebay example

require 'rubygems'
require 'scrubyt'

ebay_data = Scrubyt::Extractor.define  do

     fetch 'http://www.ebay.com/'
     fill_textfield 'satitle', 'ipod'
     submit
     
     record "//table[@class='nol']" do
       name "//td[@class='details']/div/a"
     end
end

puts ebay_data.to_xml