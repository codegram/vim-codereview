module Vim
  class Buffer
    class << self
      include Enumerable

      def each
        count.times.each { |i| yield self[i] }
      end
    end

    def reload
      Buffer.detect { |buf| buf == self }
    end

    def ==(other)
      name == other.name && number == other.number
    end
  end
end
