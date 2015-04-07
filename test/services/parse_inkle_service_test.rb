require 'test_helper'

class ParseInkleServiceTest < Minitest::Test
  def test_parse_single_paragraph
    json_string = '{ "a": { "content": [ "monkey" ] } }'
    inkle_parsed = ParseInkleService.new(json_string, 'a').parse
    assert_equal 1, inkle_parsed.count
    assert_equal 'a', inkle_parsed.first[:id]
    assert_equal ['monkey'], inkle_parsed.first[:contents]
  end

  def test_parse_multiple_linked_paragraphs_ordered
    json_string = '{
      "a": { "content": [ "monkey", { "divert": "b" } ] },
      "b": { "content": [ "man", { "divert": "c" } ] },
      "c": { "content": [ "was here"] }
    }'
    inkle_parsed = ParseInkleService.new(json_string, 'a').parse
    assert_equal 1, inkle_parsed.count
    assert_equal 'a', inkle_parsed.first[:id]
    assert_equal ['monkey', 'man', 'was here'], inkle_parsed.first[:contents]
  end

  def test_parse_multiple_linked_paragraphs_unordered
    json_string = '{
      "b": { "content": [ "man", { "divert": "c" } ] },
      "a": { "content": [ "monkey", { "divert": "b" } ] },
      "c": { "content": [ "was here"] }
    }'
    inkle_parsed = ParseInkleService.new(json_string, 'a').parse
    assert_equal 1, inkle_parsed.count
    assert_equal 'a', inkle_parsed.first[:id]
    assert_equal ['monkey', 'man', 'was here'], inkle_parsed.first[:contents]
  end
end
