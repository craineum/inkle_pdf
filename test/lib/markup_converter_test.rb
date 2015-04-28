require 'test_helper'

class MarkupConverterTest < Minitest::Test

  def test_tags
    maps = [{ from: /-/, to: 'a' }]
    converter = MarkupConverter.new maps
    assert_equal 'code <a>monkey</a>', converter.tags('code -monkey-')
  end

  def test_tags_different_start_end
    maps = [{ from_start: /\*-/, from_end: /-\*/, to_start: 'a', to_end: 'b' }]
    converter = MarkupConverter.new maps
    assert_equal 'code <a>monkey</b>', converter.tags('code *-monkey-*')
  end

  def test_tags_multiple_same_map
    maps = [{ from: /-/, to: 'a' }]
    converter = MarkupConverter.new maps
    assert_equal '<a>code</a> <a>monkey</a>', converter.tags('-code- -monkey-')
  end

  def test_tags_multiple_different_map
    maps = [{ from: /-/, to: 'a' }, { from: /_/, to: 'b' }]
    converter = MarkupConverter.new maps
    assert_equal '<a>code</a> <b>monkey</b>', converter.tags('-code- _monkey_')
  end
end
