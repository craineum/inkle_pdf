require 'open-uri'
require 'open_uri_redirections'

module CyoaBookHelper
  class CyoaBookPdf
    include Prawn::View

    def initialize(attributes={})
      default_map = [
        { from_start: /\*-/, from_end: /-\*/, to: 'b' },
        { from_start: /\/=/, from_end: /=\//, to: 'i' }
      ]
      markup_map = attributes.delete(:markup_map) { |key| [] }
      @markup_converter = attributes.delete(:markup_converter).new(
        default_map + markup_map)
      @document ||= Prawn::Document.new(attributes)
      @pages_with_footer = []
    end

    def footer(messages)
      if @pages_with_footer.exclude? page_number
        @pages_with_footer << page_number
        canvas do
          bounding_box([54, 129], width: 324, height: 113) do
            move_down (7 - messages.count) * 14
            messages.each do |message|
              text convert_markup(message), inline_format: true
            end
          end
        end
      end
    end

    def go_to_last_page
      go_to_page page_count
    end

    def page_numbers
      page = '<page>'
      odd_options = {
        at: [bounds.right + 6, bounds.top + 36],
        width: 42,
        align: :center,
        page_filter: :odd,
        start_count_at: 1,
        size: 18
      }
      even_options = {
        at: [bounds.left - 48, bounds.top + 36],
        width: 42,
        align: :center,
        page_filter: :even,
        start_count_at: 2,
        size: 18
      }
      number_pages page, odd_options
      number_pages page, even_options
    end

    def segment_contents(contents)
      contents.each do |content|
        text_formatted content
      end
    end

    private

    def convert_markup(content)
      @markup_converter.tags(content)
    end

    def header?(content)
      content.match(/<b>.*?<\/b>/).to_s == content
    end

    def image?(content)
      content.include? '<image::'
    end

    def image_file_path(content)
      img_url = content.match(/<image::(.*)?>/)[1]
      tempfile = Tempfile.new('image')
      tempfile.binmode
      tempfile.write open(img_url, allow_redirections: :safe).read
      tempfile.close
      tempfile.path
    end

    def text_formatted(content)
      content = convert_markup(content)
      options = { inline_format: true }
      if header? content
        move_down 10
        options.merge!({ align: :center, size: 16 })
      else
        options.merge!({ indent_paragraphs: 20 })
      end
      if image?(content)
        move_down 20
        options.merge!({ position: :center, scale: 0.24 })
        image image_file_path(content), options
      else
        text content, options
      end
    end
  end
end
