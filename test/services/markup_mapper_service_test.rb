require 'test_helper'

class MarkupMapperServiceTest < Minitest::Test
  def test_void_tags_mapping
    search_tags = ['**', '', '&&']
    replace_tags = ['br', '', 'hr']
    params = { 'void_tags' => search_tags, 'void_html_tags' => replace_tags }
    map = MarkupMapperService.new(params).void_tags_mapping
    assert_equal [{ from: '\*\*', to: 'br' }, { from: '&&', to: 'hr' }], map
  end

  def test_non_void_tags_mapping
    search_start_tags = ['^--', '', '#*']
    search_end_tags = ['--^', '', '*#']
    replace_tags = ['sup', '', 'div']
    params = { 'open_tags' => search_start_tags,
               'end_tags' => search_end_tags,
               'html_tags' => replace_tags }
    map = MarkupMapperService.new(params).non_void_tags_mapping
    assert_equal [{ from_start: '\^\-\-', from_end: '\-\-\^', to: 'sup' },
                  { from_start: '\#\*', from_end: '\*\#', to: 'div' }], map
  end

  def test_tags_mapping
    void_search_tags = ['**', '']
    void_replace_tags = ['br', '']
    search_start_tags = ['', '^--']
    search_end_tags = ['', '--^']
    replace_tags = ['', 'sup']
    params = { 'open_tags' => search_start_tags,
               'end_tags' => search_end_tags,
               'html_tags' => replace_tags,
               'void_tags' => void_search_tags,
               'void_html_tags' => void_replace_tags }
    map = MarkupMapperService.new(params).tags_mapping
    assert_equal [{ from_start: '\^\-\-', from_end: '\-\-\^', to: 'sup' },
                  { from: '\*\*', to: 'br' }], map
  end

  def test_missing_tags
    void_search_tags = ['**', '']
    void_replace_tags = ['', '']
    search_start_tags = ['', '^--']
    search_end_tags = ['', '']
    replace_tags = ['', 'sup']
    params = { 'open_tags' => search_start_tags,
               'end_tags' => search_end_tags,
               'html_tags' => replace_tags,
               'void_tags' => void_search_tags,
               'void_html_tags' => void_replace_tags }
    map = MarkupMapperService.new(params).tags_mapping
    assert_equal [], map
  end

  def test_filter_params
    search_tags = ['**']
    replace_tags = ['br']
    params = { 'void_tags' => search_tags,
               'void_html_tags' => replace_tags,
               'ignore_me' => 'this should be ignored' }
    map = MarkupMapperService.new(params).void_tags_mapping
    assert_equal [{ from: '\*\*', to: 'br' }], map
  end
end
