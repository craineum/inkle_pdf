require 'test_helper'

class ParseInkleServiceTest < Minitest::Test
  def test_single_paragraph
    json_string = '{ "a": { "content": [ "monkey" ] } }'
    parsed = ParseInkleService.new(json_string, 'a').parse
    assert_equal 1, parsed.count
    assert_equal 'a', parsed.first[:id]
    assert_equal ['monkey'], parsed.first[:contents]
  end

  def test_multiple_linked_paragraphs_ordered
    json_string = '{
      "a": { "content": [ "monkey", { "divert": "b" } ] },
      "b": { "content": [ "man", { "divert": "c" } ] },
      "c": { "content": [ "was here"] }
    }'
    parsed = ParseInkleService.new(json_string, 'a').parse
    assert_equal 1, parsed.count
    assert_equal 'a', parsed.first[:id]
    assert_equal ['monkey', 'man', 'was here'], parsed.first[:contents]
  end

  def test_multiple_linked_paragraphs_unordered
    json_string = '{
      "b": { "content": [ "man", { "divert": "c" } ] },
      "a": { "content": [ "monkey", { "divert": "b" } ] },
      "c": { "content": [ "was here"] }
    }'
    parsed = ParseInkleService.new(json_string, 'a').parse
    assert_equal 1, parsed.count
    assert_equal 'a', parsed.first[:id]
    assert_equal ['monkey', 'man', 'was here'], parsed.first[:contents]
  end

  def test_paragraph_with_options
    json_string = '{
      "b": { "content": [ "man", {
        "linkPath": "x", "option": "no"
      }, {
        "linkPath": "y", "option": "yes"
      } ] },
      "a": { "content": [ "monkey", { "divert": "b" } ] },
      "x": { "content": [ "was not here"] },
      "y": { "content": [ "was here", { "divert": "z" } ] },
      "z": { "content": [ "but left" ] }
    }'
    parsed = ParseInkleService.new(json_string, 'a').parse
    assert_equal 3, parsed.count

    assert_equal 'a', parsed.first[:id]
    assert_equal ['monkey', 'man'], parsed.first[:contents]
    assert_equal [{ 'x' => 'no' }, { 'y' => 'yes' }],
      parsed.first[:child_options]

    assert_equal 'x', parsed.second[:id]
    assert_equal ['was not here'], parsed.second[:contents]
    assert_equal ['a'], parsed.second[:parent_ids]

    assert_equal 'y', parsed.third[:id]
    assert_equal ['was here', 'but left'], parsed.third[:contents]
    assert_equal ['a'], parsed.third[:parent_ids]
  end

  def test_segment_with_multiple_parents
    json_string = '{
      "a": { "content": [ "Is monkey man here?", {
        "linkPath": "x", "option": "no"
      }, {
        "linkPath": "y", "option": "yes"
      }, {
        "linkPath": "z", "option": "maybe"
      } ] },
      "x": { "content": [ "left"] },
      "y": { "content": [ "was here", {
        "linkPath": "x", "option": "but"
      }, {
        "linkPath": "z", "option": "i think"
      } ] },
      "z": { "content": [ "well make sure"] }
    }'
    parsed = ParseInkleService.new(json_string, 'a').parse
    assert_equal 4, parsed.count

    assert_equal 'a', parsed.first[:id]
    assert_equal ['Is monkey man here?'], parsed.first[:contents]
    assert_equal([{ 'x' => 'no' }, { 'y' => 'yes' }, { 'z' => 'maybe' }],
                 parsed.first[:child_options])

    assert_equal 'x', parsed.second[:id]
    assert_equal ['left'], parsed.second[:contents]
    assert_equal ['a', 'y'], parsed.second[:parent_ids]

    assert_equal 'y', parsed.third[:id]
    assert_equal ['was here'], parsed.third[:contents]
    assert_equal ['a'], parsed.third[:parent_ids]
    assert_equal([{ 'x' => 'but' }, { 'z' => 'i think' }],
                 parsed.third[:child_options])

    assert_equal 'z', parsed.last[:id]
    assert_equal ['well make sure'], parsed.last[:contents]
    assert_equal ['a', 'y'], parsed.last[:parent_ids]
  end
end
