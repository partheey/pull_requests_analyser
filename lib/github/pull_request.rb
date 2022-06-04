class PullRequest < Base
  attr_reader :commits, :changes_history

  def initialize(options = {})
    super
    fetch_from_api_source('pulls', id)
    build_commits
  end

  def build_commits
    @commits = retrieve_all_commits.map { |commit| Commit.new(id: commit['sha']) }
  end
  
  def changes_history
    @changes_history ||= generate_changes_history
  end
  
  private

  def retrieve_all_commits
    response = RestClient.get retrieved_object['commits_url']
    JSON.parse response
  end
  
  def generate_changes_history
    @commits.each do |commit|
      changes_history << commit.find_changed_lines
    end
  end
end
