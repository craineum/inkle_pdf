require 'test_helper'

class BookSegmentTest < Minitest::Test
  def setup
    BookSegment.class_variable_set :@@all, []
  end

  def test_invalid_errors
    book_segment = BookSegment.new
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :id
    assert !book_segment.errors.messages.include?(:child_options)
    assert !book_segment.errors.messages.include?(:contents)
    assert !book_segment.errors.messages.include?(:page_end)
    assert !book_segment.errors.messages.include?(:page_start)
  end

  def test_id
    expected = 'abc'
    book_segment = BookSegment.new id: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.id
  end

  def test_child_options_array
    expected = [{'a' => 'A'}, {'b' => 'B'}, {'c' => 'C'}]
    book_segment = BookSegment.new id: 'x', child_options: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.child_options
  end

  def test_child_options_array_child_ids
    book_segment = BookSegment.new id: 'x',
      child_options: [{'a' => 'A'}, {'b' => 'B'}]
    assert book_segment.valid?
    assert_equal ['a', 'b'], book_segment.child_ids
  end

  def test_child_options_array_child_option
    book_segment = BookSegment.new id: 'x', child_options: [{'a' => 'A'}]
    assert book_segment.valid?
    assert_equal 'A', book_segment.child_option('a')
  end

  def test_child_options_string
    expected = 'a'
    book_segment = BookSegment.new id: 'x', child_options: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.child_options
  end

  def test_child_options_string_child_ids
    book_segment = BookSegment.new id: 'x', child_options: 'a'
    assert book_segment.valid?
    assert_equal ['a'], book_segment.child_ids
  end

  def test_child_options_string_child_option
    book_segment = BookSegment.new id: 'x', child_options: 'a'
    assert book_segment.valid?
    assert_equal nil, book_segment.child_option('a')
  end

  def test_no_child_options
    book_segment = BookSegment.new id: 'a'
    assert book_segment.valid?
    assert_equal [], book_segment.child_ids
    assert_equal nil, book_segment.child_option('b')
    assert_equal [], book_segment.children
  end

  def test_children
    segment_a = BookSegment.new id: 'a'
    segment_b = BookSegment.new id: 'b'
    book_segment = BookSegment.new id: 'x',
      child_options: [{'a' => 'A'}, {'b' => 'B'}]
    assert book_segment.valid?
    assert_equal [segment_a, segment_b], book_segment.children
  end

  def test_contents
    expected = ['a', 'b', 'c']
    book_segment = BookSegment.new id: 'x', contents: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.contents
  end

  def test_contents_is_array
    book_segment = BookSegment.new contents: 'a'
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :contents
  end

  def test_page_start
    expected = 1
    book_segment = BookSegment.new id: 'x', page_start: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.page_start
  end

  def test_page_start_number
    book_segment = BookSegment.new page_start: 'a'
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :page_start
  end

  def test_page_end
    expected = 1
    book_segment = BookSegment.new id: 'x', page_end: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.page_end
  end

  def test_page_end_number
    book_segment = BookSegment.new page_end: 'a'
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :page_end
  end

  def test_parent_ids
    expected = ['a', 'b', 'c']
    book_segment = BookSegment.new id: 'x', parent_ids: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.parent_ids
  end

  def test_parent_ids_is_array
    book_segment = BookSegment.new parent_ids: 'a'
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :parent_ids
  end

  def test_parents
    segment_a = BookSegment.new id: 'a'
    segment_b = BookSegment.new id: 'b'
    book_segment = BookSegment.new id: 'x', parent_ids: ['a', 'b']
    assert book_segment.valid?
    assert_equal [segment_a, segment_b], book_segment.parents
  end

  def test_no_parents
    book_segment = BookSegment.new id: 'a'
    assert book_segment.valid?
    assert_equal [], book_segment.parents
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
