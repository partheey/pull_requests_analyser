class Commit < Base
  attr_accessor :files, :diffs
  
  def initialize(options = {})
    super
    fetch_from_html_source('commit', id)
  end

  def find_changed_lines
    files = parsed_html.search('#files .file')
    parsed_html.search('#files include-fragment').map { |frag| files += retrieve_fragments(frag.attr('src')).search('.file') }
    @diffs = files.map do |file|
      title = file.at_css('.Link--primary').text
      numbers = file.search('.blob-num-addition.js-linkable-line-number').map{|line| line.attributes['data-line-number'].value }
      [title, numbers]
    end
  end

  def retrieve_fragments(fragment_url)
    url = "https://github.com/#{fragment_url}"
    response = RestClient.get url
    formetted_response = "<html><body>#{response.body}</html></body>"
    Nokogiri.parse formetted_response
  end

  def parsed_html
    Nokogiri.parse retrieved_html
  end
end
