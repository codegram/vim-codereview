gem 'minitest'
$: << 'lib'
require 'patch'
require 'minitest/autorun'

describe Patch do
  def loc(filename, line)
    Patch::Location.new(commit, filename, line)
  end

  let(:fixture) { File.expand_path('fixtures/example.patch', File.dirname(__FILE__)) }
  let(:commit) { "973a92b0ccf2291085d4b76ad619617288b42a73" }
  let(:patch) { Patch.new(File.read(fixture)) }

  it 'finds the line of an addition in a first hunk' do
    patch.find_addition("app/controllers/foo_controller.rb", 5).must_equal loc('app/controllers/foo_controller.rb', 6)
  end

  it 'finds the line of a deletion in a second hunk' do
    patch.find_deletion("app/controllers/foo_controller.rb", 10).must_equal loc('app/controllers/foo_controller.rb', 11)
  end

  it 'finds the line of an addition in another file' do
    patch.find_addition("app/helpers/foo_helper.rb", 3).must_equal loc('app/helpers/foo_helper.rb', 3)
  end

  it 'times out if trying to comment on context lines' do
    proc {
      patch.find_addition("app/helpers/foo_helper", 2)
    }.must_raise Patch::ProcessingTimeout
  end

  it 'times out if the patch is bogus' do
    bogus_patch = Class.new(Patch) {
      def find_change(*args)
        sleep 8
      end
    }.new("foo\nbar\nbaz")

    proc {
      bogus_patch.find_addition("app/controllers/foo_controller.rb", 5)
    }.must_raise Patch::ProcessingTimeout
  end
end
