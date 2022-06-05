Dir["./lib/github/*.rb"].each { |file| load file }

class PullsAnalyzer
  attr_reader :all_pr_ids

  def find_affected
    find_open_pull_requests.map do |pr|
      pr = PullRequest.new(id: pr).test_affection
      pr.is_affected
    end
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
  
  private
  
  def retrieve_pull_reqs(page = 1)
    url = 'https://api.github.com/repos/rails/rails/pulls?per_page=50&page=' + page.to_s
    response = RestClient.get url
    JSON.parse(response.body).map { |pr| pr['number'] }
  end
end