require 'test_helper'

class CyoaBookHelper::CyoaBookPdfTest < Minitest::Test
  include PdfInspector

  attr_accessor :cyoa_book

  def setup
    @cyoa_book = CyoaBookHelper::CyoaBookPdf.new
  end

  def test_footer_single
    cyoa_book.footer ['Monkey Foot']
    assert_pdf_has_content? cyoa_book.render, 'Monkey Foot'
  end

  def test_footer_multiple
    cyoa_book.footer ['Monkey Foot', 'Ape Feet']
    assert_pdf_has_content? cyoa_book.render, 'Monkey Foot Ape Feet'
  end

  def test_footer_same_page
    cyoa_book.footer ['Monkey Foot']
    cyoa_book.footer ['Not Here']
    assert_pdf_has_content? cyoa_book.render, 'Monkey Foot'
    assert_pdf_has_no_content? cyoa_book.render, 'Not Here'
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
    cyoa_book.segment_contents ['monkey', 'man!']
    assert_pdf_has_content? cyoa_book.render, 'monkey man!'
  end
end
