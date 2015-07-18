require 'test_helper'

class CyoaBookHelper::CyoaBookPdfTest < Minitest::Test
  include PdfInspector

  attr_accessor :cyoa_book

  def setup
    @markup_converter = Minitest::Mock.new
    markup_converter_class = Minitest::Mock.new
    default_map = [
      { from_start: /\*-/, from_end: /-\*/, to: 'b' },
      { from_start: /\/=/, from_end: /=\//, to: 'i' }
    ]
    markup_map = [
      { from_start: /\*\^/, from_end: /\^\*/, to: 'sup' }
    ]
    map = default_map + markup_map
    markup_converter_class.expect :new, @markup_converter, [map]
    @cyoa_book = CyoaBookHelper::CyoaBookPdf.new(
      { markup_converter: markup_converter_class, markup_map: markup_map })
  end

  def test_footer_single
    @markup_converter.expect :tags, 'Monkey', ['Monkey']
    cyoa_book.footer ['Monkey']
    assert_pdf_has_content? cyoa_book.render, 'Monkey'
  end

  def test_footer_multiple
    @markup_converter.expect :tags, 'Monkey A', ['Monkey A']
    @markup_converter.expect :tags, 'Monkeys B', ['Monkeys B']
    cyoa_book.footer ['Monkey A', 'Monkeys B']
    assert_pdf_has_content? cyoa_book.render, 'Monkey A Monkeys B'
  end

  def test_footer_same_page
    @markup_converter.expect :tags, 'Monkey', ['Monkey']
    cyoa_book.footer ['Monkey']
    cyoa_book.footer ['Not Here']
    assert_pdf_has_content? cyoa_book.render, 'Monkey'
    assert_pdf_has_no_content? cyoa_book.render, 'Not Here'
  end

  def test_footer_styles
    @markup_converter.expect :tags, '<b>Monkey A</b>', ['*-Monkey A-*']
    @markup_converter.expect :tags, '<i>Monkeys B</i>', ['/=Monkeys B=/']
    @markup_converter.expect :tags, '<sup>Monkeys C</sup>', ['*^Monkeys C^*']
    cyoa_book.footer ['*-Monkey A-*', '/=Monkeys B=/', '*^Monkeys C^*']
    assert_pdf_has_content? cyoa_book.render, 'Monkey A'
    assert_pdf_has_content? cyoa_book.render, 'Monkeys B'
    assert_pdf_has_content? cyoa_book.render, 'Monkeys C'
    @markup_converter.verify
  end

  def test_go_to_last_page
    cyoa_book.start_new_page
    cyoa_book.start_new_page
    cyoa_book.go_to_page 1
    assert_equal 1, cyoa_book.page_number
    cyoa_book.go_to_last_page
    assert_equal 3, cyoa_book.page_number
  end

  def test_page_numbers
    cyoa_book.start_new_page
    cyoa_book.page_numbers
    assert_pdf_has_content? cyoa_book.render, '1 2'
  end

  def test_segment_contents
    @markup_converter.expect :tags, 'monkey', ['monkey']
    @markup_converter.expect :tags, 'man!', ['man!']
    cyoa_book.segment_contents ['monkey', 'man!']
    assert_pdf_has_content? cyoa_book.render, 'monkey man!'
  end

  def test_segment_contents_styles
    text = '/=bold=/ *-monkey-* *^banana^*'
    @markup_converter.expect :tags,
      '<i>bold</i> <b>monkey</b> <sup>banana</sup>', [text]
    cyoa_book.segment_contents [text]
    assert_pdf_has_content? cyoa_book.render, 'bold'
    assert_pdf_has_content? cyoa_book.render, 'monkey'
    assert_pdf_has_content? cyoa_book.render, 'banana'
    @markup_converter.verify
  end
end
