require 'test_helper'

class MarkupConverterTest < Minitest::Test

  def test_void_tag
    maps = [{ from: /-/, to: 'a' }]
    converter = MarkupConverter.new maps
    assert_equal 'code <a /> monkey', converter.tags('code - monkey')
  end

  def test_void_tag_multiple
    maps = [{ from: /-/, to: 'a' }]
    converter = MarkupConverter.new maps
    assert_equal 'code <a /> <a /> monkey', converter.tags('code - - monkey')
  end

  def test_tag
    maps = [{ from_start: /\*-/, from_end: /-\*/, to: 'a' }]
    converter = MarkupConverter.new maps
    assert_equal 'code <a>monkey</a>', converter.tags('code *-monkey-*')
  end

  def test_tag_multiple
    maps = [{ from_start: /\*-/, from_end: /-\*/, to: 'a' }]
    converter = MarkupConverter.new maps
    assert_equal '<a>code</a> <a>monkey</a>',
      converter.tags('*-code-* *-monkey-*')
  end

  def test_tags_multiple
    maps = [{ from_start: /\*-/, from_end: /-\*/, to: 'a' },
            { from_start: /\*=/, from_end: /=\*/, to: 'b' },
            { from: /-/, to: 'c' }]
    converter = MarkupConverter.new maps
    assert_equal '<a>code</a> <c /> <b>monkey</b>',
      converter.tags('*-code-* - *=monkey=*')
  end
end
