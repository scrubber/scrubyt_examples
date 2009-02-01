=begin
Solution of Ruby Quiz #189 (Gathering Ruby Quiz 2 Data)
http://groups.google.com/group/comp.lang.ruby/browse_thread/thread/4513b44130d99305/2cb8ae40ee685de8?#2cb8ae40ee685de8

Explanation from the Ruby Quiz master:

The one solution to this week's quiz come from Peter Szinek using
scRUBYt [http://scrubyt.org/]. Despite being just over fifty lines
long there is a lot packed in here, so let's dive in.

Here we begin by seting up a scRUBYt Extractor and set it to get the
main Ruby Quiz 2 page.

  #scrape the stuff with sRUBYt!
  data = Scrubyt::Extractor.define do
    fetch 'http://splatbang.com/rubyquiz/'

The 'quiz' sets up a node in the XML document, retrieving elements
that match the XPath. This yields all the links in the side area, that
is, links to all the quizzes.

    quiz "//div[@id='side']/ol/li/a[1]" do
      link_url do
        quiz_id /id=(\d+)/
        quiz_link /id=(.+)/ do

These next two sections download the description and summary for each
quiz. They are saved into temporary files to be loaded into the XML
document at the end. Notice the use of lambda, it takes in the match
from /id=(.+)/ in the quiz_link. So for example when the link is
'quiz.rhtml?id=157_The_Smallest_Circle' it matches
'157_The_Smallest_Circle' and passes it into the lambda which returns
it as "http://splatbang.com/rubyquiz/157_The_Smallest_Circle/quiz.txt"
which is the text for the quiz. The summary is gathered in a likewise
fashion.

          quiz_desc_url(lambda {|quiz_dir|
"http://splatbang.com/rubyquiz/#{quiz_dir}/quiz.txt"}, :type =>
:script) do
            quiz_dl 'descriptions', :type => :download
          end
          quiz_summary_url(lambda {|quiz_dir|
"http://splatbang.com/rubyquiz/#{quiz_dir}/summ.txt"}, :type =>
:script) do
            quiz_dl 'summaries', :type => :download
          end
        end
      end

This next part gets all the solutions for each quiz. It follows the
link_url from the side area. Once on the new page it creates a node
for each solution, again by using XPath to get all the links in the
list on the side. It populates each solution with an author: the text
from the html anchor tag. It populates the ruby_talk_reference with
the href attribute of the tag. In order to get the solution text it
follows (resolves) the link and returns the text within the "//pre[1]"
element, again using XPath to specify. The text node is added as a
child node to the solution.

      quiz_detail :resolve => "http://splatbang.com/rubyquiz" do
        solution "/html/body/div/div[2]/ol/li/a" do
          author lambda {|solution_link_text| solution_link_text},
:type => :script
          ruby_talk_reference "href", :type => :attribute
          solution_detail :resolve => :full do
            text "//pre[1]"
          end
        end
      end

This select_indices limits the scope of the quiz gathering to just the
first three, usefull for testing since we don't want to have to
traverse the entire site to see if code works. I removed it when
gathering the full dataset.

    end.select_indices(0..2)
  end

This next part, using Nokogiri, loads the files that were saved
temporarily and inserts them into the XML document. It also removes
the link_url nodes to clean up the final output to match the output
specified in the quiz.

  result = Nokogiri::XML(data.to_xml)

  (result/"//quiz").each do |quiz|
    quiz_id = quiz.text[/\s(\d+)\s/,1].to_i
    file_index = quiz_id > 157 ? "_#{(quiz_id - 157)}" : ""
    (quiz/"//link_url").first.unlink

    desc = Nokogiri::XML::Element.new("description", quiz.document)
    desc.content =open("descriptions/quiz#{file_index}.txt").read
    quiz.add_child(desc)

    summary = Nokogiri::XML::Element.new("summary", quiz.document)
    summary.content =open("summaries/summ#{file_index}.txt").read
    quiz.add_child(summary)
  end

And finally save the result to an xml file on the filesystem:

  open("ruby_quiz_archive.xml", "w") {|f| f.write result}

This was my first experience with scRUBYt and it took me a little
while to "get it". It packs a lot of power into a concise syntax and
is definitely worth considering for your next web scraping needs.
=end

require 'rubygems'
require 'scrubyt'
require 'nokogiri'

#scrape the stuff with sRUBYt!
data = Scrubyt::Extractor.define do
  fetch 'http://splatbang.com/rubyquiz/'

  quiz "//div[@id='side']/ol/li/a[1]" do
    link_url do 
      quiz_id /id=(\d+)/
      quiz_link /id=(.+)/ do
        quiz_desc_url lambda {|quiz_dir| "http://splatbang.com/rubyquiz/#{quiz_dir}/quiz.txt"}, :type => :script do
          quiz_dl 'descriptions', :type => :download
        end
        quiz_summary_url lambda {|quiz_dir| "http://splatbang.com/rubyquiz/#{quiz_dir}/summ.txt"}, :type => :script do
          quiz_dl 'summaries', :type => :download
        end        
      end           
    end    
    quiz_detail :resolve => "http://splatbang.com/rubyquiz" do
      solution "/html/body/div/div[2]/ol/li/a" do
        author lambda {|solution_link_text| solution_link_text}, :type => :script
        ruby_talk_reference "href", :type => :attribute
        solution_detail :resolve => :full do
          text "//pre[1]"
        end
      end
    end
  end.select_indices(0..2)
end

#post process with Nokogiri
result = Nokogiri::XML(data.to_xml)

(result/"//quiz").each do |quiz|  
  quiz_id = quiz.text[/\s(\d+)\s/,1].to_i
  file_index = quiz_id > 157 ? "_#{(quiz_id - 157)}" : ""  
  (quiz/"//link_url").first.unlink

  desc = Nokogiri::XML::Element.new("description", quiz.document)
  desc.content =open("descriptions/quiz#{file_index}.txt").read
  quiz.add_child(desc)

  summary = Nokogiri::XML::Element.new("summary", quiz.document)
  summary.content =open("summaries/summ#{file_index}.txt").read
  quiz.add_child(summary)   
end

open("ruby_quiz_archive.xml", "w") {|f| f.write result}