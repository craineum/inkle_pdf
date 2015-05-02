require 'test_helper'

class BookSegmentsTest < Minitest::Test
  def test_add
    segments = BookSegments.new.add [id: 'a']
    assert_equal 1, segments.count
  end

  def test_valid?
    segments = BookSegments.new.add [id: 'a']
    assert segments.valid?
  end

  def test_enumerable
    segments = BookSegments.new.add [id: 'a']
    assert_equal 1, segments.count
    assert_equal 'a', segments.first.id
  end
end
