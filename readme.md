## Problem Statement

We believe that commits in a proper pull request stand on their own. There should be no “editing
history”, meaning that each changed row in each file should only be affected by a single commit
only.

Provide a github link of your solution for the following:

Crawl the rails/rails github repo and list all the pull requests where there are rows in files
affected by multiple commits. Please provide links to the specific rows as well


## Solution

At first, all the open pull requests details are obtained via a public rest api request to github. Then each pull request is instantiated as PullRequest instance. This PullRequest instance retrieves the commits for this pull request. With the retrieved commit sha, the commit instance will generated for all retrieved commits. Then each commit will retrieve html page in which added_lines & removed_lines are obtained. 

Based on these attributes{added_lines & removed_lines} the Changes Info is intiantiaed. Once all this is complete, the pull requet setups changes_history by checkins each commits. Using the changes_history, the repeated files_line-number across commits is identified.

Finally, The reults are printed to an new file - './result.txt'


### Entities

Below are the entities that were desinged to operate in this solution.

- PullsAnalyzer
- PullRequest
- Commit
- ChangesInfo