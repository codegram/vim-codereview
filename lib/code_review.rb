require 'tempfile'
require 'json'

class CodeReview
  TOKEN_PATH = File.expand_path("~/.codereview")

  def self.current
    @current
  end

  def self.review(url)
    @current = new(url)
    @current.review
  end

  def initialize(url)
    @url        = url
    @token      = authentication_token
    @patch_path = download_patch
    @patch      = File.readlines(@patch_path)
    @data       = pull_request_data
  end

  def review
    `git stash; git checkout #{data[:base]}`
    Vim.command("PatchReview #{patch_path}")
  end

  def comment
    win0 = VIM::Window[0]
    win1 = VIM::Window[1]
    win = win0.buffer.name ? win1 : win0

    name = win.buffer.name
    line_number = VIM::Buffer.current.line_number

    line = VIM::Buffer.current[line_number]
    puts "Searching for #{line}"

    match = @patch.detect { |x| p x; x =~ /#{Regexp.escape(line)}/ }
    p match

    puts "NAME: #{name}, LINE: #{line}"
  end

  private
  attr_reader :url, :token, :patch_path, :data, :patch

  def authentication_token
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

  def download_patch
    download_pull_request("application/vnd.github.v3.patch")
  end

  def pull_request_data
    path = download_pull_request("application/json")
    data = JSON.parse(File.read(path))
    {
      :head => data["head"]["sha"],
      :base => data["base"]["sha"],
      :merged => data["merged"]
    }
  end

  def download_pull_request(content_type)
    user, repo, pull = url.scan(/github\.com\/(.*)\/(.*)\/pull\/(\d+)/).first
    temp = Tempfile.new("review-#{user}-#{repo}-#{pull}.patch")
    puts "Downloading Pull Request #{user}/#{repo}##{pull}..."
    `curl --silent -H "Authorization: token #{token}" -H "Accept: #{content_type}" -L -o #{temp.path} https://api.github.com/repos/#{user}/#{repo}/pulls/#{pull}`
    temp.path
  end
end