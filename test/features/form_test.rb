require 'test_helper'

class FormTest < Capybara::Rails::TestCase
  include PdfInspector

  test 'load form' do
    visit root_path
    page.assert_selector 'form'
    page.assert_selector '#inkle_file'
  end

  test 'submit form get pdf' do
    visit root_path
    attach_file :inkle_file, 'test/fixtures/sample.json'
    click_button 'Submit'
    assert_equal 'application/pdf', page.response_headers['Content-Type']
    assert_pdf_has_content? page.source, 'The Robit Riddle'
    assert_pdf_page_count page.source, 25
  end
end
