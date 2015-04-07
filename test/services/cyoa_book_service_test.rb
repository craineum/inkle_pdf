require 'test_helper'

class CyoaBookServiceTest < Minitest::Test
  include PdfInspector

  def setup
    BookSegment.class_variable_set :@@all, []
  end

  def test_single_page_book
    book_segment = BookSegment.new id: 'a', contents: ['some contents']
    cyoa_pdf = CyoaBookService.new.render
    assert_equal 1, book_segment.page_start
    assert_equal 1, book_segment.page_end
    assert_pdf_has_content? cyoa_pdf, 'some contents'
    assert_pdf_page_count cyoa_pdf, 1
  end

  def test_multi_page_segment
    paragraph_a = Faker::Lorem.paragraph(50)
    paragraph_b = Faker::Lorem.paragraph(50)
    book_segment = BookSegment.new id: 'a', contents: [paragraph_a, paragraph_b]
    cyoa_pdf = CyoaBookService.new.render
    assert_equal 1, book_segment.page_start
    assert_equal 2, book_segment.page_end
    assert_pdf_has_content? cyoa_pdf, paragraph_a
    assert_pdf_page_count cyoa_pdf, 2
  end
end
