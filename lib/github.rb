require 'json'
require 'timeout'

class Github
  TimeoutError = Class.new(Timeout::Error)
  TIMEOUT = 3

  TOKEN_PATH = File.expand_path("~/.codereview")

  def initialize(pull_request_url)
    @url = pull_request_url
  end

  def post_pull_request_comment(body, location)
    body = JSON.dump({
      body: body,
      commit_id: location.commit_id,
      path: location.path,
      position: location.position
    })

    curl %{--silent -X POST -H "Accept: application/json" -H "Content-type: application/json" -H "Authorization: token #{token}" #{base_api_url}/comments -d '#{body}'}
    :OK
  end

  def patch_path
    @patch_path ||= download_pull_request("application/vnd.github.v3.patch")
  end

  def pull_request_data
    @pull_request_data ||= begin
      path = download_pull_request("application/json")
      data = JSON.parse(File.read(path))
      {
        :head => data["head"]["sha"],
        :base => data["base"]["sha"],
        :merged => data["merged"]
      }
    end
  end

  private
  attr_reader :url

  def token
    @token ||= begin
      if File.exist?(TOKEN_PATH)
        File.read(TOKEN_PATH)
      else
        token = Vim.evaluate("input('Create a GitHub authorization token and paste hit here: ')")
        File.open(TOKEN_PATH, "w") do |file|
          file.write token
        end
        token
      end
    end
  end

  def download_pull_request(content_type)
    user, repo, pull = url_info
    temp = Tempfile.new("review-#{user}-#{repo}-#{pull}.patch")
    puts "Downloading Pull Request #{user}/#{repo}##{pull}..."
    curl %Q{--silent -H "Authorization: token #{token}" -H "Accept: #{content_type}" -L -o #{temp.path} #{base_api_url}}
    temp.path
  end

  def url_info
    url.scan(/github\.com\/(.*)\/(.*)\/pull\/(\d+)/).first
  end

  def base_api_url
    user, repo, pull = url_info
    "https://api.github.com/repos/#{user}/#{repo}/pulls/#{pull}"
  end

  def curl(args)
    Timeout.timeout(TIMEOUT) { `curl #{args}` }
  rescue Timeout::Error=>e
    raise TimeoutError, e.message
  end
end
