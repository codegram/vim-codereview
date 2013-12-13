gem 'minitest'
$: << 'lib'
require 'patch'
require 'minitest/autorun'

describe Patch do
  def loc(commit, filename, line)
    Patch::Location.new(commit, filename, line)
  end

  let(:fixture) { File.expand_path('fixtures/example.patch', File.dirname(__FILE__)) }
  let(:first_commit) { "973a92b0ccf2291085d4b76ad619617288b42a73" }
  let(:last_commit) { "124a92b0ccf2291085d4b76ad619617288b42a73" }
  let(:patch) { Patch.new(File.read(fixture)) }

  it 'finds the line of an addition in a first hunk' do
    patch.find_addition(
      "app/controllers/foo_controller.rb", 5,
      "    render :foo"
    ).must_equal loc(first_commit, 'app/controllers/foo_controller.rb', 6)
  end

  it 'finds the line of a deletion in a second hunk' do
    patch.find_deletion(
      "app/controllers/foo_controller.rb", 10,
      "    do_baz"
    ).must_equal loc(first_commit, 'app/controllers/foo_controller.rb', 11)
  end

  it 'finds the line of an addition in another file' do
    patch.find_addition(
      "app/helpers/foo_helper.rb", 3,
      "  def render_foos"
    ).must_equal loc(first_commit, 'app/helpers/foo_helper.rb', 3)
  end

  it 'finds the line of a deletion in another commit' do
    patch.find_deletion(
      "app/controllers/foo_controller.rb", 4,
      "    @foo = Foo.new"
    ).must_equal loc(last_commit, 'app/controllers/foo_controller.rb', 4)
  end

  it 'rejects finding changes on context lines' do
    proc {
      patch.find_addition(
        "app/helpers/foo_helper", 2, "module FooHelper"
      )
    }.must_raise Patch::ProcessingError
  end

  it 'rejects bogus patches' do
    bogus_patch = Patch.new("foo\nbar\nbaz")

    proc {
      bogus_patch.find_addition(
        "app/controllers/foo_controller.rb", 5,
        "foo"
      )
    }.must_raise Patch::ProcessingError
  end
end
