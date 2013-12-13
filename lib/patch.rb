require_relative 'patch/chunk'

class Patch
  ProcessingError = Class.new(StandardError)
  Location = Struct.new(:commit_id, :path, :position)

  def initialize(patch)
    @patch = patch
  end

  def find_addition(filename, subjective_line, text)
    find_change(filename, subjective_line, :+, text)
  end

  def find_deletion(filename, subjective_line, text)
    find_change(filename, subjective_line, :-, text)
  end

  def find_change(filename, subjective_line, kind, text)
    chunks
      .select { |chunk| chunk.filename == filename }
      .reverse
      .each { |chunk|
        if location = chunk.find_change(subjective_line, kind, text)
          return location
        end
    }
    raise ProcessingError, "Couldn't find that line in the diff patch. Remember that you can only comment on additions or deletions."
  end

  private

  def chunks
    @chunks ||= Chunk.from_patch(@patch)
  end
end