gem 'minitest'
$: << 'lib'
require 'patch'
require 'minitest/autorun'

describe Patch::Chunk do
  def loc(commit, filename, offset)
    Patch::Location.new(commit, filename, offset)
  end

  let(:fixture) { File.expand_path('../fixtures/example.patch', File.dirname(__FILE__)) }
  let(:patch) { File.read(fixture) }

  describe '.from_patch' do
    it 'divides the patch in chunks' do
      Patch::Chunk.from_patch(patch).length.must_equal 3
    end

    it 'gets the filename from each chunk' do
      Patch::Chunk.from_patch(patch).map(&:filename).must_equal %w(
        app/controllers/foo_controller.rb
        app/helpers/foo_helper.rb
        app/controllers/foo_controller.rb
      )
    end
  end

  describe '#find_change' do
    let(:first_chunk) { Patch::Chunk.from_patch(patch).first }
    let(:last_chunk) { Patch::Chunk.from_patch(patch).last }

    it 'finds an addition and returns the offset' do
      first_chunk.find_change(5, :+, "    render :foo").must_equal(
        loc(
          '973a92b0ccf2291085d4b76ad619617288b42a73',
          'app/controllers/foo_controller.rb', 6
        )
      )
    end

    it 'finds a deletion' do
      first_chunk.find_change(5, :-, "    render :bar").must_equal(
        loc(
          '973a92b0ccf2291085d4b76ad619617288b42a73',
          'app/controllers/foo_controller.rb', 5
        )
      )
    end

    it 'finds a deletion in later parts of the chunk' do
      first_chunk.find_change(10, :-, "    do_baz").must_equal(
        loc(
          '973a92b0ccf2291085d4b76ad619617288b42a73',
          'app/controllers/foo_controller.rb', 11
        )
      )
    end

    it 'finds an addition in a different commit' do
      last_chunk.find_change(5, :+, "    @foo = Foo.new(arguments)").must_equal(
        loc(
          '124a92b0ccf2291085d4b76ad619617288b42a73',
          'app/controllers/foo_controller.rb', 5
        a
      )
    end
  end
end
