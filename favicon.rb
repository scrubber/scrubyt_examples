require 'rubygems'
require 'scrubyt'

# Simple exmaple for scraping the variety of favicon URLs from a particular site
# Scrubyt.logger = Scrubyt::Logger.new

favicon_url = Scrubyt::Extractor.define do
  fetch 'http://www.tumblr.com/'

  favicon '//head' do
    favicon_url         "//link[@rel='shortcut icon']/@href"
    icon_url            "//link[@rel='icon']/@href"
    apple_iphone_icon   "//link[@rel='apple-touch-icon]/@href"
  end
end

puts favicon_url.to_xml
