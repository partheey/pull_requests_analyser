class PullRequest < Base
  attr_reader :commits, :changes_history, :is_affected, :affected_line_urls

  def initialize(options = {})
    super
    # fetch_from_api_source('pulls', id)
  end
  
  def test_affection
    build_commits
    build_changes_history
    check_affection
    self
  end
  
  def build_changes_history
    @changes_history ||= generate_changes_history
  end
  
  def build_commits
    @commits = retrieve_all_commits.map { |commit_sha| Commit.new(id: commit_sha) }
  end
  
  def check_affection
    files = find_affected_files
    line_numbers = files.any? ? check_lines_match(files) : []
    set_affected(files, line_numbers) if (files.any?  && line_numbers.any?)
  end

  def check_lines_match(files)
    lines = files.map { |file| file.all_changes }.flatten.tally.select { |k,v| v > 1 }
    lines.keys
  end
  
  def find_affected_files
    grouped_changes = @changes_history.group_by { |change| change.file_path }
    files_with_changes_in_more_commits = grouped_changes.select { |file, changes| changes.count > 1 }
    files_with_changes_in_more_commits.values.flatten
  end
  
  private

  def set_affected(files, lines)
    @affected_line_urls = []
    is_affected = true
    lines.each do |line|
      files.each do |file|
        @affected_line_urls << build_line_url(file, line) if file.all_changes.include?(line) 
      end
    end
  end

  def build_line_url(file, line)
    line_suffix = file.added_lines.include?(line) ? "R#{line}" : "L#{line}"
    "#{HTML_HOST}/pull/#{id}/commits/#{file.commit_id}##{file.diff_id}#{line_suffix}"
  end
  
  def retrieve_all_commits
    commits_url = "https://github.com/rails/rails/pull/#{id}/commits"
    response = RestClient.get commits_url
    Nokogiri.parse(response).search('#commits_bucket li.Box-row').map { |elm| find_commit_id(elm) }
  end
  
  def generate_changes_history
    @changes_history = []
    @commits.each do |commit|
      @changes_history += commit.find_changed_lines
    end
    @changes_history
  end

  def find_commit_id(node)
    node.attr('data-url').split('/')[4]
  end
end
