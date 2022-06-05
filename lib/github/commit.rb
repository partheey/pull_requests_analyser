class Commit < Base
  attr_accessor :files, :diffs
  ChangedLine = Struct.new(:file_path, :commit_id, :diff_id, :removed_lines, :added_lines) do
    def all_changes
      (removed_lines.to_a + added_lines.to_a).uniq
    end
  end

  def initialize(options = {})
    super
    fetch_from_html_source('commit', id)
  end

  def find_changed_lines
    find_file_fragments
    @diffs = files.map do |file|
      title = file.at_css('.Link--primary').text
      diff_id = file.attr('id')
      added_lines = file.search('.blob-num-addition.js-linkable-line-number').map{|line| line.attributes['data-line-number'].value }
      removed_lines = file.search('.blob-num-deletion.js-linkable-line-number').map{|line| line.attributes['data-line-number'].value }
      ChangedLine.new(title, self.id, diff_id, added_lines, removed_lines)
    end
  end
  
  def parsed_html
    Nokogiri.parse retrieved_html
  end
  
  def find_file_fragments
    @files = parsed_html.search('#files .file')
    parsed_html.search('#files include-fragment').map do |frag| 
      @files += retrieve_fragments(frag.attr('src')).search('.file')
    end
    files
  end

  def retrieve_fragments(fragment_url)
    url = "https://github.com/#{fragment_url}"
    response = RestClient.get url
    formetted_response = "<html><body>#{response.body}</html></body>"
    Nokogiri.parse formetted_response
  end
end
