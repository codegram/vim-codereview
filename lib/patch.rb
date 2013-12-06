require 'timeout'

class Patch
  ProcessingTimeout = Class.new(Timeout::Error)
  Location = Struct.new(:commit_id, :path, :position)
  TIMEOUT = 1

  def initialize(patch)
    @patch = ("\n" + patch).split("\n")
  end

  def find_addition(filename, subjective_line)
    with_timeout { find_change(filename, subjective_line, :addition) }
  end

  def find_deletion(filename, subjective_line)
    with_timeout { find_change(filename, subjective_line, :deletion) }
  end

  private

  def with_timeout(&block)
    Timeout.timeout(TIMEOUT, &block)
  rescue Timeout::Error
    raise ProcessingTimeout, "Couldn't find that line in the diff patch. Remember that you can only comment on additions or deletions."
  end

  #TODO: kill me plz
  def find_change(filename, subjective_line, type)
    find = Regexp.escape(type == :addition ? '+' : '-')
    skip = Regexp.escape(type == :addition ? '-' : '+')

    line = 1
    commit = @patch[line].scan(/From ([a-z0-9]+)/).first.first
    line += 1 until @patch[line] =~ /\+\+\+ b\/#{filename}/
    line += 1

    header = @patch[line]

    starts = header.scan(/@@ -(\d+)/).first.first.to_i

    offset = (subjective_line - starts + 1)

    (subjective_line - starts + 1).times do |i|
      line +=1
      if @patch[line] =~ /^#{skip}/
        line += 1
        offset += 1
      end
    end

    while(@patch[line] !~ /^#{find}/)
      (line += 1 && offset += 1) until ((header = @patch[line]) =~ /@@/)
      starts = header.scan(/@@ -(\d)/).first.first.to_i
      new_offset = (subjective_line - starts + 1)
      (subjective_line - starts + 1).times do |i|
        line +=1
        if @patch[line] =~ /^#{skip}/
          line +=1
          new_offset += 1
        end
      end
      offset += new_offset
    end

    Location.new(commit, filename, offset)
  end
end