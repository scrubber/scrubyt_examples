require 'rubygems'
require 'scrubyt'

# Simple exmaple for scraping basic
# information from a public Twitter
# account.

# Scrubyt.logger = Scrubyt::Logger.new

twitter_data = Scrubyt::Extractor.define do
  fetch 'http://www.twitter.com/scobleizer'

  profile_info '//ul[@class="about vcard entry-author"]' do
    full_name  "//li//span[@class='fn']"
    location   "//li//span[@class='adr']"
    website    "//li//a[@class='url']/@href"
    bio        "//li//span[@class='bio']"
  end
end

puts twitter_data.to_xml
