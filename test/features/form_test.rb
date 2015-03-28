require 'test_helper'

class FormTest < Capybara::Rails::TestCase
  test 'load form' do
    visit root_path
    page.assert_selector 'form'
    page.assert_selector '#inkle_file'
  end

  test 'submit form' do
    visit root_path
    attach_file :inkle_file, 'test/fixtures/sample.json'
    click_button 'Submit'
    assert_content page, 'create'
  end
end
