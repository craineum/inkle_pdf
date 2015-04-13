require 'test_helper'

class CyoaBookServiceTest < Minitest::Test
  include PdfInspector

  def setup
    BookSegment.class_variable_set :@@all, []
  end

  def test_title_author
    cyoa_pdf = CyoaBookService.new('Monkey!', 'Monkey Man').render
    assert_pdf_page_count cyoa_pdf, 1
    assert_pdf_has_content? cyoa_pdf, 'Monkey! by Monkey Man'
  end

  def test_default_title_author
    cyoa_pdf = CyoaBookService.new.render
    assert_pdf_page_count cyoa_pdf, 1
    assert_pdf_has_content? cyoa_pdf, 'Untitled by Unknown'
  end

  def test_single_page_book
    book_segment = BookSegment.new id: 'a', contents: ['monkey man!']
    cyoa_pdf = CyoaBookService.new.render
    assert_pdf_page_count cyoa_pdf, 2
    assert_equal 2, book_segment.page_start
    assert_equal 2, book_segment.page_end
    assert_pdf_has_content? cyoa_pdf, 'monkey man!'
    assert_pdf_has_content? cyoa_pdf, 'The End'
  end

  def test_multi_page_segment
    paragraph_a = Faker::Lorem.paragraph(30)
    paragraph_b = Faker::Lorem.paragraph(30)
    book_segment = BookSegment.new id: 'a', contents: [paragraph_a, paragraph_b]
    cyoa_pdf = CyoaBookService.new.render
    assert_pdf_page_count cyoa_pdf, 3
    assert_equal 2, book_segment.page_start
    assert_equal 3, book_segment.page_end
    assert_pdf_has_content? cyoa_pdf, paragraph_a
    assert_pdf_has_content? cyoa_pdf, paragraph_b[1..10]
    assert_pdf_has_content? cyoa_pdf, paragraph_b[-1..-10]
    assert_pdf_has_content? cyoa_pdf, 'Turn to the next page'
    assert_pdf_has_content? cyoa_pdf, 'The End'
  end

  def test_branch
    book = [{
      id: 'a',
      contents: ['monkey', 'man'],
      child_options: [{ 'x' => 'no' }, { 'y' => 'yes' }]
    },{
      id: 'x', contents: ['was not here'], parent_ids: ['a']
    },{
      id: 'y', contents: ['was here', 'but left'], parent_ids: ['a']
    }]
    BookSegment.add(*book)
    cyoa_pdf = CyoaBookService.new.render
    assert_pdf_page_count cyoa_pdf, 4
    BookSegment.each_with_index do |book_segment, index|
      assert_equal (index + 2), book_segment.page_start
      assert_equal (index + 2), book_segment.page_end
    end
    assert_pdf_has_content? cyoa_pdf, 'monkey man'
    assert_pdf_has_content? cyoa_pdf, 'no - Turn to page 3'
    assert_pdf_has_content? cyoa_pdf, 'yes - Turn to page 4'
    assert_pdf_has_content? cyoa_pdf, 'was not here'
    assert_pdf_has_content? cyoa_pdf, 'was here but left'
    assert_pdf_has_content? cyoa_pdf, 'The End'
  end
end
