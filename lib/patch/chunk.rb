class Patch
  class Chunk
    class Part
      def initialize(offset, line, body)
        @offset = offset
        @line = line
        @lines = body.each_line.to_a
      end

      def find_change(subjective_line, kind, text)
        index = subjective_line - @line
        while @lines[index] && @lines[index].chomp != "#{kind}#{text}".chomp
          index += 1
        end
        return @offset + index if @lines[index]
      end
    end

    def self.from_patch(patch)
      commit = nil
      patch
        .split(/^From ([a-f0-9]{40})/).drop(1)
        .chunk { |line| !!(line =~ /^[a-f0-9]{40}$/) }
        .map { |(is_commit, elements)|
          if is_commit
            commit = elements.first
            nil
          else
            elements.join("\n").split(/^diff --git /).drop(1).map do |raw_chunk|
              filename = raw_chunk.scan(/^a\/(.*) b\/.*$/).first.first
              body = raw_chunk.split(/--- .*\n\+\+\+ .*\n/)
              .drop(1).first
              .gsub(/--\n\d\.\d.*/m, '').chomp
              new(commit, filename, body)
            end
          end
        }.compact.flatten
    end

    attr_reader :filename

    def initialize(commit, filename, body)
      @commit = commit
      @filename = filename
      @parts = body.split("@@ -").drop(1).map { |raw_part|
        header = raw_part.split("\n").first
        offset = body.split("\n").index("@@ -#{header}")
        line = raw_part.scan(/^(\d+),\d+ \+(\d+),/).first.map(&:to_i).max
        Part.new(offset, line, "@@ -" + raw_part)
      }
    end

    def find_change(subjective_line, kind, text)
      @parts.each do |part|
        if chunk_offset = part.find_change(subjective_line, kind, text)
          return Location.new(@commit, @filename, chunk_offset)
        end
      end
      nil
    end
  end
end
