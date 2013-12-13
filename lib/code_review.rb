require 'tempfile'
require 'json'
require_relative 'patch'
require_relative 'github'
require_relative 'vim_ext'

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
    Vim.command "PatchReview #{patch_path}"
    Vim.command "file Overview"
    Vim.command "setlocal buftype=nofile"
    reload_comments
  end

  def new_change_comment
    contents = File.read(patch_path)

    win0 = VIM::Window[0]
    win1 = VIM::Window[1]
    win2 = VIM::Window[2]
    filename = (win0.buffer.name || win1.buffer.name || win2.buffer.name).gsub(Vim.evaluate('getcwd()') + '/', '')
    current_file = VIM::Buffer.current.name ? :original : :patched
    line_number = VIM::Buffer.current.line_number
    text = VIM::Buffer.current[line_number].chomp

    patch = Patch.new(contents)
    @location = if current_file == :original
      patch.find_deletion(filename, line_number, text)
    else
      patch.find_addition(filename, line_number, text)
    end

    Vim.command "vsplit New_Change_Comment"
    Vim.command "normal! ggdG"
    Vim.command "setlocal buftype=nofile"
    Vim.command "silent nnoremap <buffer> <leader>c :ruby CodeReview.current.create_change_comment<cr>"
    Vim.command %Q{echo "Write your commit message in this window, then type <leader>c when you're done. And be constructive! :)"}
  end

  def create_change_comment
    if !@location
      raise ArgumentError, "Can't create a comment from a non-comment buffer. Call :CodeReviewComment first."
    end

    buf = VIM::Buffer.current
    contents = buf.count.times.map { |i| buf[i+1] }.join("\n")
    Vim.command %Q{echo "Posting comment to GitHub..."}
    github.post_change_comment(contents, @location)
    Vim.command "bd"
    Vim.command %Q{echo "Comment posted successfully."}
  end

  def new_comment
    Vim.command "vsplit New_Comment"
    Vim.command "normal! ggdG"
    Vim.command "setlocal buftype=nofile"
    Vim.command "silent nnoremap <buffer> <leader>c :ruby CodeReview.current.create_comment<cr>"
    Vim.command %Q{echo "Write your commit message in this window, then type <leader>c when you're done. And be constructive! :)"}
  end

  def create_comment
    Vim.command %Q{echo "Posting comment to GitHub..."}
    buf = VIM::Buffer.current
    contents = buf.count.times.map { |i| buf[i+1] }.join("\n")
    github.post_comment(contents)
    Vim.command "bd"
    Vim.command %Q{echo "Comment posted successfully."}
    reload_comments
  end

  def reload_comments
    Vim.command "tabfirst"
    Vim.command "tabnext" until VIM::Buffer.current == overview_buffer
    Vim.command "%d"
    (["PULL REQUEST COMMENTS", "Type :CodeReviewComment to add yours", ""] + render_comments.split("\n")).each_with_index do |line, idx|
      overview_buffer.append(idx, line)
    end
  end

  private
  attr_reader :github

  def overview_buffer
    @overview_buffer ||= begin
      idx = VIM::Buffer.count.times.detect { |i| VIM::Buffer[i].name =~ /Overview$/ }
      idx ? VIM::Buffer[idx] : raise(RuntimeError, "Can't find Overview buffer -- did you close it?")
    end
  end

  def render_comments
    github.get_comments.map(&:to_s).join("\n\n")
  end

  def patch_path
    github.patch_path
  end

  def pull_request_data
    github.pull_request_data
  end
end