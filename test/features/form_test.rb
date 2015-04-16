require 'test_helper'

class FormTest < Capybara::Rails::TestCase
  include PdfInspector

  def test_load_form
    visit root_path
    page.assert_selector 'form'
    page.assert_selector '#inkle_url'
  end

  def test_submit_json_url
    inkle_url = 'https://writer.inklestudios.com/stories/musgraveritual.json'
    visit root_path
    fill_in 'Inkle URL', with: inkle_url
    click_button 'Submit'
    assert_equal 'application/pdf', page.response_headers['Content-Type']
    assert_pdf_has_content? page.source, 'The Robit Riddle'
    assert_pdf_page_count page.source, 25
  end

  def test_submit_url
    inkle_url = 'https://writer.inklestudios.com/stories/musgraveritual'
    visit root_path
    fill_in 'Inkle URL', with: inkle_url
    click_button 'Submit'
    assert_equal 'application/pdf', page.response_headers['Content-Type']
    assert_pdf_has_content? page.source, 'The Robit Riddle'
    assert_pdf_page_count page.source, 25
  end

  def test_submit_inkle_story_id
    visit root_path
    fill_in 'Inkle URL', with: 'musgraveritual'
    click_button 'Submit'
    assert_equal 'application/pdf', page.response_headers['Content-Type']
    assert_pdf_has_content? page.source, 'The Robit Riddle'
    assert_pdf_page_count page.source, 25
  end
end
