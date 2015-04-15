require 'test_helper'

class ParseInkleServiceTest < Minitest::Test
  def wrap_json_string(payload)
    '{ "data": {
      "initial": "a",
      "stitches": ' + payload + '} }'
  end

  def test_author
    json_string = '{ "data": {
      "editorData": { "authorName": "Monkey Man" } }
    }'
    author = ParseInkleService.new(json_string).author
    assert_equal 'Monkey Man', author
  end

  def test_no_author
    author = ParseInkleService.new('{}').author
    assert_equal nil, author
  end

  def test_title
    json_string = '{ "title": "The Monkey Way" }'
    title = ParseInkleService.new(json_string).title
    assert_equal 'The Monkey Way', title
  end

  def test_no_title
    title = ParseInkleService.new('{}').title
    assert_equal nil, title
  end

  def test_single_paragraph
    json_string = wrap_json_string '{ "a": { "content": [ "monkey" ] } }'
    parsed = ParseInkleService.new(json_string).segments
    assert_equal 1, parsed.count
    assert_equal 'a', parsed.first[:id]
    assert_equal ['monkey'], parsed.first[:contents]
  end

  def test_multiple_linked_paragraphs_unordered
    json_string = wrap_json_string '{
      "b": { "content": [ "man", { "divert": "c" } ] },
      "a": { "content": [ "monkey", { "divert": "b" } ] },
      "c": { "content": [ "was here"] }
    }'
    parsed = ParseInkleService.new(json_string).segments
    assert_equal 1, parsed.count
    assert_equal 'a', parsed.first[:id]
    assert_equal ['monkey', 'man', 'was here'], parsed.first[:contents]
  end

  def test_paragraph_with_options
    json_string = wrap_json_string '{
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
    parsed = ParseInkleService.new(json_string).segments
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
    json_string = wrap_json_string '{
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
    parsed = ParseInkleService.new(json_string).segments
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

  def test_paragraph_with_multiple_parents
    json_string = wrap_json_string '{
      "a": { "content": [ "monkey", {
        "linkPath": "x", "option": "boy"
      }, {
        "linkPath": "y", "option": "girl"
      } ] },
      "x": { "content": [ "is handsome", { "divert": "z" } ] },
      "y": { "content": [ "is beautiful", { "divert": "z" } ] },
      "z": { "content": [ "and smart"] }
    }'
    parsed = ParseInkleService.new(json_string).segments
    assert_equal 4, parsed.count

    assert_equal 'a', parsed.first[:id]
    assert_equal ['monkey'], parsed.first[:contents]
    assert_equal([{ 'x' => 'boy' }, { 'y' => 'girl' }],
                 parsed.first[:child_options])

    assert_equal 'x', parsed.second[:id]
    assert_equal ['is handsome'], parsed.second[:contents]
    assert_equal ['a'], parsed.second[:parent_ids]
    assert_equal('z', parsed.second[:child_options])

    assert_equal 'y', parsed.third[:id]
    assert_equal ['is beautiful'], parsed.third[:contents]
    assert_equal ['a'], parsed.third[:parent_ids]
    assert_equal('z', parsed.third[:child_options])

    assert_equal 'z', parsed.last[:id]
    assert_equal ['and smart'], parsed.last[:contents]
    assert_equal ['x', 'y'], parsed.last[:parent_ids]
  end

  def test_paragraph_with_different_types_parents
    json_string = wrap_json_string '{
      "a": { "content": [ "monkey", {
        "linkPath": "x", "option": "boy"
      }, {
        "linkPath": "y", "option": "girl"
      } ] },
      "x": { "content": [ "is handsome", { "divert": "y" } ] },
      "y": { "content": [ "is beautiful", { "divert": "z" } ] },
      "z": { "content": [ "and smart"] }
    }'
    parsed = ParseInkleService.new(json_string).segments
    assert_equal 3, parsed.count

    assert_equal 'a', parsed.first[:id]
    assert_equal ['monkey'], parsed.first[:contents]
    assert_equal([{ 'x' => 'boy' }, { 'y' => 'girl' }],
                 parsed.first[:child_options])

    assert_equal 'x', parsed.second[:id]
    assert_equal ['is handsome'], parsed.second[:contents]
    assert_equal ['a'], parsed.second[:parent_ids]
    assert_equal('y', parsed.second[:child_options])

    assert_equal 'y', parsed.third[:id]
    assert_equal ['is beautiful', 'and smart'], parsed.third[:contents]
    assert_equal ['a', 'x'], parsed.third[:parent_ids]
    assert_equal(nil, parsed.third[:child_options])
  end
end
