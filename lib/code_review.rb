require 'tempfile'
require 'json'

class CodeReview
  TOKEN_PATH = File.expand_path("~/.codereview")

  def self.review(url)
    token      = authentication_token
    patch_path = download_patch token, url
    data       = pull_request_data token, url

    `git stash; git checkout #{data[:base]}`

    # command = data[:merged] ? "ReversePatchReview" : "PatchReview"
    command = "PatchReview"
    Vim.command("#{command} #{patch_path}")
  end

  private

  def self.authentication_token
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

  def self.download_patch(token, url)
    download_pull_request(token, url, "application/vnd.github.v3.patch")
  end

  def self.pull_request_data(token, url)
    path = download_pull_request(token, url, "application/json")
    data = JSON.parse(File.read(path))
    {
      :head => data["head"]["sha"],
      :base => data["base"]["sha"],
      :merged => data["merged"]
    }
  end

  def self.download_pull_request(token, url, content_type)
    user, repo, pull = url.scan(/github\.com\/(.*)\/(.*)\/pull\/(\d+)/).first
    temp = Tempfile.new("review-#{user}-#{repo}-#{pull}.patch")
    puts "Downloading Pull Request #{user}/#{repo}##{pull}..."
    `curl --silent -H "Authorization: token #{token}" -H "Accept: #{content_type}" -L -o #{temp.path} https://api.github.com/repos/#{user}/#{repo}/pulls/#{pull}`
    temp.path
  end
end