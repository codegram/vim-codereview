require 'tempfile'
require 'json'
require_relative 'patch'
require_relative 'github'

class CodeReview
  def self.current
    @current
  end

  def self.review(url)
    @current = new(url)
    @current.review
  end

  def initialize(url)
    @github = Github.new(url)
  end

  def review
    `git stash; git checkout #{pull_request_data[:base]}`
    Vim.command("PatchReview #{patch_path}")
  end

  def comment
    contents = File.read(patch_path)

    win0 = VIM::Window[0]
    win1 = VIM::Window[1]
    filename = (win0.buffer.name || win1.buffer.name).gsub(Vim.evaluate('getcwd()') + '/', '')
    current_file = VIM::Buffer.current.name ? :original : :patched
    line_number = VIM::Buffer.current.line_number

    patch = Patch.new(contents)
    location = if current_file == :original
      patch.find_deletion(filename, line_number)
    else
      patch.find_addition(filename, line_number)
    end

    puts github.post_pull_request_comment("TESTIN!", location)
  end

  private
  attr_reader :github

  def patch_path
    github.patch_path
  end

  def pull_request_data
    github.pull_request_data
  end
end