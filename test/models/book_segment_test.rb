require 'test_helper'

class BookSegmentTest < Minitest::Test
  def setup
    BookSegment.class_variable_set :@@all, []
  end

  def test_add
    segments = BookSegment.add [id: 'a']
    assert_equal segments, BookSegment
    assert_equal 1, BookSegment.count
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

  def test_no_child_options
    book_segment = BookSegment.new id: 'a'
    assert book_segment.valid?
    assert_equal [], book_segment.child_ids
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

  def test_footer_end_false
    book_segment = BookSegment.new id: 'x', child_options: 'a'
    assert !book_segment.footer_end?
    assert_equal nil, book_segment.footer_end
  end

  def test_footer_end_true
    book_segment = BookSegment.new id: 'x', page_end: 1
    assert book_segment.footer_end?
    assert_equal [{ page: 1, footers: ['The End'] }], book_segment.footer_end
  end

  def test_footer_next_false
    book_segment = BookSegment.new id: 'x', page_start: 1, page_end: 1
    assert !book_segment.footer_next?
    assert_equal nil, book_segment.footer_next
  end

  def test_footer_next_true
    book_segment = BookSegment.new id: 'x', page_start: 1, page_end: 2
    assert book_segment.footer_next?
    assert_equal [{ page: 1, footers: ['Turn to the next page'] }],
      book_segment.footer_next
  end

  def test_footer_options_false
    BookSegment.new id: 'a'
    book_segment = BookSegment.new id: 'x', child_options: 'a'
    assert !book_segment.footer_options?
    assert_equal nil, book_segment.footer_options
  end

  def test_footer_options_multiple
    BookSegment.new id: 'a', page_start: 2
    BookSegment.new id: 'b', page_start: 3
    book_segment = BookSegment.new id: 'x',
      child_options: [{ 'a' => 'Monkey' }, { 'b' => 'Monkeys' }],
      page_end: 1
    assert book_segment.footer_options?
    expected = [{ page: 1, footers: ['Monkey - Turn to page 2',
                                     'Monkeys - Turn to page 3'] }]
    assert_equal expected, book_segment.footer_options
  end

  def test_footer_options_no_children
    book_segment = BookSegment.new id: 'x'
    assert !book_segment.footer_options?
    assert_equal nil, book_segment.footer_options
  end

  def test_footer_options_no_page
    BookSegment.new id: 'a', page_start: 2
    book_segment = BookSegment.new id: 'x', child_options: 'a'
    assert !book_segment.footer_options?
    assert_equal nil, book_segment.footer_options
  end

  def test_footer_options_true
    BookSegment.new id: 'a', page_start: 2
    book_segment = BookSegment.new id: 'x', child_options: 'a', page_end: 1
    assert book_segment.footer_options?
    assert_equal [{ page: 1, footers: ['Turn to page 2'] }],
      book_segment.footer_options
  end

  def test_footers_false
    parent_segment = BookSegment.new id: 'a',
      child_options: [{ 'x' => 'X' }, { 'y' => 'Y' }]
    book_segment = BookSegment.new id: 'x',
      child_options: 'b',
      page_start: 1,
      page_end: 1,
      parent_ids: ['a']
    BookSegment.new id: 'y'
    assert !book_segment.footer_end?
    assert !book_segment.footer_next?
    assert !book_segment.parents_footers?
    assert !parent_segment.footer_options?
    assert !book_segment.footers?
    assert_equal nil, book_segment.footers
  end

  def test_footers_true_end
    parent_segment = BookSegment.new id: 'a',
      child_options: [{ 'x' => 'X' }, { 'y' => 'Y' }]
    book_segment = BookSegment.new id: 'x',
      page_start: 1,
      page_end: 1,
      parent_ids: ['a']
    BookSegment.new id: 'y'
    assert book_segment.footer_end?
    assert !book_segment.footer_next?
    assert !book_segment.parents_footers?
    assert !parent_segment.footer_options?
    assert book_segment.footers?
    assert_equal [{ page: 1, footers:['The End'] }], book_segment.footers
  end

  def test_footers_true_next
    parent_segment = BookSegment.new id: 'a',
      child_options: [{ 'x' => 'X' }, { 'y' => 'Y' }]
    book_segment = BookSegment.new id: 'x',
      child_options: 'b',
      page_start: 1,
      page_end: 2,
      parent_ids: ['a']
    BookSegment.new id: 'y'
    assert !book_segment.footer_end?
    assert book_segment.footer_next?
    assert !book_segment.parents_footers?
    assert !parent_segment.footer_options?
    assert book_segment.footers?
    assert_equal [{ page: 1, footers:['Turn to the next page'] }],
      book_segment.footers
  end

  def test_footers_true_options
    book_segment = BookSegment.new id: 'a',
      page_start: 1,
      page_end: 1,
      child_options: [{ 'x' => 'X' }, { 'y' => 'Y' }]
    BookSegment.new id: 'x',
      child_options: 'b',
      page_start: 2,
      parent_ids: ['a']
    BookSegment.new id: 'y', page_start: 3
    assert !book_segment.footer_end?
    assert !book_segment.footer_next?
    assert !book_segment.parents_footers?
    assert book_segment.footer_options?
    assert book_segment.footers?
    expected = [{ page: 1, footers: ['X - Turn to page 2',
                                     'Y - Turn to page 3'] }]
    assert_equal expected, book_segment.footers
  end

  def test_footers_true_parent
    parent_segment = BookSegment.new id: 'a',
      page_end: 1,
      child_options: [{ 'x' => 'X' }, { 'y' => 'Y' }]
    book_segment = BookSegment.new id: 'x',
      child_options: 'b',
      page_start: 2,
      page_end: 2,
      parent_ids: ['a']
    BookSegment.new id: 'y', page_start: 3
    assert !book_segment.footer_end?
    assert !book_segment.footer_next?
    assert book_segment.parents_footers?
    assert parent_segment.footer_options?
    assert book_segment.footers?
    expected = [{ page: 1, footers: ['X - Turn to page 2',
                                     'Y - Turn to page 3'] }]
    assert_equal expected, book_segment.footers
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

  def test_parents_footers_false
    BookSegment.new id: 'a', child_options: 'x'
    book_segment = BookSegment.new id: 'x', parent_ids: ['a']
    assert !book_segment.parents_footers?
    assert_equal nil, book_segment.parents_footers
  end

  def test_parents_footers_no_parents
    book_segment = BookSegment.new id: 'x'
    assert !book_segment.parents_footers?
    assert_equal nil, book_segment.parents_footers
  end

  def test_parents_footers_true
    BookSegment.new id: 'a', child_options: 'x', page_end: 1
    book_segment = BookSegment.new id: 'x', parent_ids: ['a'], page_start: 2
    assert book_segment.parents_footers?
    expected = [{ page: 1, footers: ['Turn to page 2'] }]
    assert_equal expected, book_segment.parents_footers
  end

  def test_parents_footers
    BookSegment.new id: 'a', page_end: 1, child_options: 'x'
    BookSegment.new id: 'b'
    book_segment = BookSegment.new id: 'x',
      page_start: 2,
      parent_ids: ['a', 'b']
    assert book_segment.parents_footers?
    expected = [{ page: 1, footers: ['Turn to page 2'] }]
    assert_equal expected, book_segment.parents_footers
  end
end
