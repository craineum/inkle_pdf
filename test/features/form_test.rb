require 'test_helper'

class FormTest < Capybara::Rails::TestCase
  include PdfInspector

  def test_load_form
    visit root_path
    page.assert_selector 'form'
    page.assert_selector '#inkle_url'
  end

  def test_default_options
    visit root_path
    fill_in 'Inkle URL', with: 'musgraveritual'
    click_button 'Submit'
    assert_equal 'application/pdf; charset=utf-8',
      page.response_headers['Content-Type']
    assert_pdf_has_content? page.source, 'The Adventure of the Musgrave Ritual'
    assert_pdf_has_content? page.source, 'Sir Arthur Conan Doyle'
    assert_pdf_page_count page.source, 67
  end

  def test_title_page
    visit root_path
    uncheck 'Include Title Page'
    fill_in 'Inkle URL', with: 'musgraveritual'
    click_button 'Submit'
    assert_equal 'application/pdf; charset=utf-8',
      page.response_headers['Content-Type']
    assert_pdf_has_no_content? page.source,
      'The Adventure of the Musgrave Ritual'
    assert_pdf_has_no_content? page.source, 'Sir Arthur Conan Doyle'
    assert_pdf_page_count page.source, 66
  end
end
