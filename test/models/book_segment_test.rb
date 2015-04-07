require 'test_helper'

class BookSegmentTest < Minitest::Test
  def setup
    BookSegment.class_variable_set :@@all, []
  end

  def test_presence
    book_segment = BookSegment.new
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :id
    assert !book_segment.errors.messages.include?(:contents)
    assert !book_segment.errors.messages.include?(:page_start)
    assert !book_segment.errors.messages.include?(:page_end)
  end

  def test_id
    expected = 'abc'
    book_segment = BookSegment.new id: expected
    assert_equal expected, book_segment.id
  end

  def test_contents
    expected = ['a', 'b', 'c']
    book_segment = BookSegment.new contents: expected
    assert_equal expected, book_segment.contents
  end

  def test_contents_is_array
    book_segment = BookSegment.new contents: 'a'
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :contents
  end

  def test_page_start
    expected = 1
    book_segment = BookSegment.new page_start: expected
    assert_equal expected, book_segment.page_start
  end

  def test_page_start_number
    book_segment = BookSegment.new page_start: 'a'
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :page_start
  end

  def test_page_end
    expected = 1
    book_segment = BookSegment.new page_end: expected
    assert_equal expected, book_segment.page_end
  end

  def test_page_end_number
    book_segment = BookSegment.new page_end: 'a'
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :page_end
  end

  def test_add_one
    BookSegment.add id: 'a'
    assert_equal 1, BookSegment.count
  end

  def test_add_two
    BookSegment.add({ id: 'a', contents:[ '1' ] }, { id: 'b' })
    assert_equal 2, BookSegment.count
  end

  def test_valid?
    BookSegment.new id: 'a'
    assert BookSegment.valid?
  end

  def test_enumerable
    BookSegment.new id: 'a'
    assert_equal 1, BookSegment.count
    assert_equal 'a', BookSegment.first.id
  end
end
