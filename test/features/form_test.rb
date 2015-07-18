require 'test_helper'

class FormTest < Capybara::Rails::TestCase
  include PdfInspector

  def teardown
    super
    Capybara.use_default_driver
  end

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
    title = 'The Adventure of the Musgrave Ritual'
    author = 'Sir Arthur Conan Doyle'
    sentence = 'I took it from him, intrigued {mischevious > 1:despite my churlish state of mind}.'
    assert_pdf_has_content? page.source, title
    assert_pdf_has_content? page.source, author
    assert_pdf_has_content? page.source, sentence
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

  def test_markup_mapping
    Capybara.current_driver = Capybara.javascript_driver

    visit root_path
    fill_in 'Inkle URL', with: 'musgraveritual'

    find(".markup-map:first-child input[type='checkbox']").click
    fill_in 'void_tags[]', with: ':'
    fill_in 'void_html_tags[]', with: 'br'

    click_button '+'
    fill_in 'open_tags[]', with: '{'
    fill_in 'end_tags[]', with: '}'
    fill_in 'html_tags[]', with: 'sup'

    click_button 'Submit'
    not_have_sentence = '{burn papers:"We should burn these infernal '\
      'papers of yours, Holmes. Keep this room warm and put them to some '\
      'use."|"More coal, Holmes?"}'
    have_sentence = '"We should burn these infernal '\
      'papers of yours, Holmes. Keep this room warm and put them to some '\
      'use."|"More coal, Holmes?"'
    5.times { click_button 'next' }
    assert page.has_content? have_sentence
    assert page.has_no_content? not_have_sentence
  end
end
