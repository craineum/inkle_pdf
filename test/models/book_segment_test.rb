require 'test_helper'

class BookSegmentTest < Minitest::Test

  def test_invalid_errors
    book_segment = BookSegment.new []
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :id
    assert !book_segment.errors.messages.include?(:child_options)
    assert !book_segment.errors.messages.include?(:contents)
    assert !book_segment.errors.messages.include?(:page_end)
    assert !book_segment.errors.messages.include?(:page_start)
  end

  def test_id
    expected = 'abc'
    book_segment = BookSegment.new [], id: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.id
  end

  def test_child_options_array
    expected = [{'a' => 'A'}, {'b' => 'B'}, {'c' => 'C'}]
    book_segment = BookSegment.new [], id: 'x', child_options: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.child_options
  end

  def test_child_options_array_child_ids
    book_segment = BookSegment.new [], id: 'x',
      child_options: [{'a' => 'A'}, {'b' => 'B'}]
    assert book_segment.valid?
    assert_equal ['a', 'b'], book_segment.child_ids
  end

  def test_child_options_string
    expected = 'a'
    book_segment = BookSegment.new [], id: 'x', child_options: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.child_options
  end

  def test_child_options_string_child_ids
    book_segment = BookSegment.new [], id: 'x', child_options: 'a'
    assert book_segment.valid?
    assert_equal ['a'], book_segment.child_ids
  end

  def test_no_child_options
    book_segment = BookSegment.new [], id: 'a'
    assert book_segment.valid?
    assert_equal [], book_segment.child_ids
    assert_equal [], book_segment.children
  end

  def test_children
    child_segment_a = BookSegment.new [], id: 'a'
    child_segment_b = BookSegment.new [], id: 'b'
    book_segment = BookSegment.new [child_segment_a, child_segment_b],
      id: 'x', child_options: [{'a' => 'A'}, {'b' => 'B'}]
    assert book_segment.valid?
    assert_equal [child_segment_a, child_segment_b], book_segment.children
  end

  def test_contents
    expected = ['a', 'b', 'c']
    book_segment = BookSegment.new [], id: 'x', contents: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.contents
  end

  def test_contents_is_array
    book_segment = BookSegment.new [], contents: 'a'
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :contents
  end

  def test_footer_end_false
    book_segment = BookSegment.new [], id: 'x', child_options: 'a'
    assert !book_segment.footer_end?
    assert_equal nil, book_segment.footer_end
  end

  def test_footer_end_true
    book_segment = BookSegment.new [], id: 'x', page_end: 1
    assert book_segment.footer_end?
    assert_equal [{ page: 1, footers: ['The End'] }], book_segment.footer_end
  end

  def test_footer_next_false
    book_segment = BookSegment.new [], id: 'x', page_start: 1, page_end: 1
    assert !book_segment.footer_next?
    assert_equal nil, book_segment.footer_next
  end

  def test_footer_next_true
    book_segment = BookSegment.new [], id: 'x', page_start: 1, page_end: 2
    assert book_segment.footer_next?
    assert_equal [{ page: 1, footers: ['Turn to the next page'] }],
      book_segment.footer_next
  end

  def test_footer_options_false
    child_segment = BookSegment.new [], id: 'a'
    book_segment = BookSegment.new [child_segment], id: 'x', child_options: 'a'
    assert !book_segment.footer_options?
    assert_equal nil, book_segment.footer_options
  end

  def test_footer_options_multiple
    child_segment_a = BookSegment.new [], id: 'a', page_start: 2
    child_segment_b = BookSegment.new [], id: 'b', page_start: 3
    book_segment = BookSegment.new [child_segment_a, child_segment_b], id: 'x',
      child_options: [{ 'a' => 'Monkey' }, { 'b' => 'Monkeys' }],
      page_end: 1
    assert book_segment.footer_options?
    expected = [{ page: 1, footers: ['Monkey - Turn to page 2',
                                     'Monkeys - Turn to page 3'] }]
    assert_equal expected, book_segment.footer_options
  end

  def test_footer_options_no_children
    book_segment = BookSegment.new [], id: 'x'
    assert !book_segment.footer_options?
    assert_equal nil, book_segment.footer_options
  end

  def test_footer_options_no_page
    child_segment = BookSegment.new [], id: 'a', page_start: 2
    book_segment = BookSegment.new [child_segment], id: 'x', child_options: 'a'
    assert !book_segment.footer_options?
    assert_equal nil, book_segment.footer_options
  end

  def test_footer_options_true
    child_segment = BookSegment.new [], id: 'a', page_start: 2
    book_segment = BookSegment.new [child_segment],
      id: 'x', child_options: 'a', page_end: 1
    assert book_segment.footer_options?
    assert_equal [{ page: 1, footers: ['Turn to page 2'] }],
      book_segment.footer_options
  end

  def test_footers_false
    segments = []
    segments << parent_segment = BookSegment.new(segments, id: 'a',
      child_options: [{ 'x' => 'X' }, { 'y' => 'Y' }])
    segments << book_segment = BookSegment.new(segments, id: 'x',
      child_options: 'b',
      page_start: 1,
      page_end: 1,
      parent_ids: ['a'])
    segments << BookSegment.new(segments, id: 'y')
    assert !book_segment.footer_end?
    assert !book_segment.footer_next?
    assert !book_segment.parents_footers?
    assert !parent_segment.footer_options?
    assert !book_segment.footers?
    assert_equal nil, book_segment.footers
  end

  def test_footers_true_end
    segments = []
    segments << parent_segment = BookSegment.new(segments, id: 'a',
      child_options: [{ 'x' => 'X' }, { 'y' => 'Y' }])
    segments << book_segment = BookSegment.new(segments, id: 'x',
      page_start: 1, page_end: 1, parent_ids: ['a'])
    segments << BookSegment.new(segments, id: 'y')
    assert book_segment.footer_end?
    assert !book_segment.footer_next?
    assert !book_segment.parents_footers?
    assert !parent_segment.footer_options?
    assert book_segment.footers?
    assert_equal [{ page: 1, footers:['The End'] }], book_segment.footers
  end

  def test_footers_true_next
    segments = []
    segments << parent_segment = BookSegment.new(segments, id: 'a',
      child_options: [{ 'x' => 'X' }, { 'y' => 'Y' }])
    segments << book_segment = BookSegment.new(segments, id: 'x',
      child_options: 'b', page_start: 1, page_end: 2, parent_ids: ['a'])
    segments << BookSegment.new(segments, id: 'y')
    assert !book_segment.footer_end?
    assert book_segment.footer_next?
    assert !book_segment.parents_footers?
    assert !parent_segment.footer_options?
    assert book_segment.footers?
    assert_equal [{ page: 1, footers:['Turn to the next page'] }],
      book_segment.footers
  end

  def test_footers_true_options
    segments = []
    segments << book_segment = BookSegment.new(segments, id: 'a',
      page_start: 1,
      page_end: 1,
      child_options: [{ 'x' => 'X' }, { 'y' => 'Y' }])
    segments << BookSegment.new(segments, id: 'x',
      child_options: 'b',
      page_start: 2,
      parent_ids: ['a'])
    segments << BookSegment.new(segments, id: 'y', page_start: 3)
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
    segments = []
    segments << parent_segment = BookSegment.new(segments, id: 'a',
      page_end: 1, child_options: [{ 'x' => 'X' }, { 'y' => 'Y' }])
    segments << book_segment = BookSegment.new(segments, id: 'x',
      child_options: 'b', page_start: 2, page_end: 2, parent_ids: ['a'])
    segments << BookSegment.new(segments, id: 'y', page_start: 3)
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
    book_segment = BookSegment.new [], id: 'x', page_start: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.page_start
  end

  def test_page_start_number
    book_segment = BookSegment.new [], page_start: 'a'
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :page_start
  end

  def test_page_end
    expected = 1
    book_segment = BookSegment.new [], id: 'x', page_end: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.page_end
  end

  def test_page_end_number
    book_segment = BookSegment.new [], page_end: 'a'
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :page_end
  end

  def test_parent_ids
    expected = ['a', 'b', 'c']
    book_segment = BookSegment.new [], id: 'x', parent_ids: expected
    assert book_segment.valid?
    assert_equal expected, book_segment.parent_ids
  end

  def test_parent_ids_is_array
    book_segment = BookSegment.new [], parent_ids: 'a'
    assert book_segment.invalid?
    assert book_segment.errors.messages.include? :parent_ids
  end

  def test_parents
    parent_segment_a = BookSegment.new [], id: 'a'
    parent_segment_b = BookSegment.new [], id: 'b'
    book_segment = BookSegment.new [parent_segment_a, parent_segment_b],
      id: 'x', parent_ids: ['a', 'b']
    assert book_segment.valid?
    assert_equal [parent_segment_a, parent_segment_b], book_segment.parents
  end

  def test_no_parents
    book_segment = BookSegment.new [], id: 'a'
    assert book_segment.valid?
    assert_equal [], book_segment.parents
  end

  def test_parents_footers_false
    BookSegment.new [], id: 'a', child_options: 'x'
    book_segment = BookSegment.new [], id: 'x', parent_ids: ['a']
    assert !book_segment.parents_footers?
    assert_equal nil, book_segment.parents_footers
  end

  def test_parents_footers_no_parents
    book_segment = BookSegment.new [], id: 'x'
    assert !book_segment.parents_footers?
    assert_equal nil, book_segment.parents_footers
  end

  def test_parents_footers_true
    segments = []
    segments << BookSegment.new(segments,
      id: 'a', child_options: 'x', page_end: 1)
    segments << book_segment = BookSegment.new(segments,
      id: 'x', parent_ids: ['a'], page_start: 2)
    assert book_segment.parents_footers?
    expected = [{ page: 1, footers: ['Turn to page 2'] }]
    assert_equal expected, book_segment.parents_footers
  end

  def test_parents_footers
    segments = []
    segments << BookSegment.new(segments,
      id: 'a', page_end: 1, child_options: 'x')
    segments << BookSegment.new(segments, id: 'b')
    segments << book_segment = BookSegment.new(segments,
      id: 'x', page_start: 2, parent_ids: ['a', 'b'])
    assert book_segment.parents_footers?
    expected = [{ page: 1, footers: ['Turn to page 2'] }]
    assert_equal expected, book_segment.parents_footers
  end
end
