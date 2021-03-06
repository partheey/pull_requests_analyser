Dir["./lib/github/*.rb"].each { |file| load file }

class PullsAnalyzer
  attr_reader :all_pr_ids, :affected_pull_requests

  def initialize()
    @affected_pull_requests = []
  end

  def find_affected
    puts "Starting......"
    find_open_pull_requests.map do |pr|
      pr = PullRequest.new(id: pr)
      pr.test_affection
      @affected_pull_requests << pr if pr.is_affected
      puts "PR ##{pr.id} ------- #{pr.is_affected ? 'Affected' : 'Not Affected'}"
    end
    puts '===================================================='
    puts "Total open PR's - #{@all_pr_ids.count}"
    puts "Total affected PR's - #{affected_pull_requests.count}"
    puts '===================================================='
    print_to_file
    puts "Completed......"
  end
  
  def find_open_pull_requests
    @all_pr_ids = []
    page = 1
    while (page != nil)
      response = retrieve_pull_reqs(page)
      @all_pr_ids += response
      (response.count < 100)? page = nil : page += 1
    end
    @all_pr_ids
  end

  def print_to_file(path = './result.txt')
    file = File.open(path, 'w')
    affected_pull_requests.each.with_index(1) do |pr, i|
      file.puts '#############################################'
      file.puts "Pull request ##{pr.id} - #{pr.html_url}"
      file.puts pr.affected_line_urls
      file.puts '#############################################'
    end
    file.puts '===================================================='
    file.puts "Total open PR's - #{@all_pr_ids.count}"
    file.puts "Total affected PR's - #{affected_pull_requests.count}"
    file.puts '===================================================='
    file.close
  end
  
  private
  
  def retrieve_pull_reqs(page = 1)
    url = "https://api.github.com/repos/rails/rails/pulls?per_page=100&page=#{page}"
    response = RestClient.get url
    JSON.parse(response.body).map { |pr| pr['number'] }
  end
end