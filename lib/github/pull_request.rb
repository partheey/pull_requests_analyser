class PullRequest < Base
  attr_reader :commits, :changes_history, :is_affected, :affected_line_urls

  def initialize(options = {})
    super
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
    affected_lines = files.any? ? find_affected_lines(files) : []
    set_affected(affected_lines) if affected_lines.any?
  end

  def find_affected_lines(files)
    files.map do |file_path, changes| 
      lines = changes.map(&:all_changes).flatten.tally.select { |k,v| v > 1 }.keys
      lines.empty? ? nil : [file_path, lines, changes]
    end.compact
  end
  
  def find_affected_files
    grouped_changes = @changes_history.group_by { |change| change.file_path }
    files_with_changes_in_more_commits = grouped_changes.select { |file, changes| changes.count > 1 }
    files_with_changes_in_more_commits
  end

  def html_url
    "#{HTML_HOST}/pull/#{id}"
  end
  
  private

  def set_affected(affected_lines)
    @affected_line_urls = []
    @is_affected = true
    affected_lines.each do |file_path, lines, changes|
      lines.each do |line|
        changes.each do |change|
          @affected_line_urls << build_line_url(change, line)
        end
      end
    end
  end

  def build_line_url(file, line)
    line_suffix = file.added_lines.include?(line) ? "R#{line}" : "L#{line}"
    "#{HTML_HOST}/pull/#{id}/commits/#{file.commit_id}##{file.diff_id}#{line_suffix}"
  end
  
  def retrieve_all_commits
    commits_url = "#{HTML_HOST}/pull/#{id}/commits"
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
