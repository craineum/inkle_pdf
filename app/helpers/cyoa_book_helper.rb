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
      return nil unless @pages_with_footer.exclude? page_number
      @pages_with_footer << page_number
      canvas do
        start_top = 30
        top = start_top if messages.size < 2
        top = start_top + ((messages.size - 1) * 12) if messages.size > 1

        transparent(0.5) do
          stroke_line [30, top + 8], [274, top + 8]
          fill_color 'EEEEEE'
          fill_rectangle [30, top + 6], 244, (messages.size * 12) + 12
        end

        bounding_box([36, top], width: 232, height: messages.size * 12) do
          messages.each do |message|
            text convert_markup(message),
              inline_format: true,
              size: 10,
              overflow: :shrink_to_fit,
              min_font_size: 8
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
        at: [bounds.right + 6, bounds.top + 18],
        width: 24,
        align: :center,
        page_filter: :odd,
        start_count_at: 1,
        size: 14
      }
      even_options = {
        at: [bounds.left - 30, bounds.top + 18],
        width: 24,
        align: :center,
        page_filter: :even,
        start_count_at: 2,
        size: 14
      }
      number_pages page, odd_options
      number_pages page, even_options
    end

    def segment_contents(contents, footer_size = 1)
      max_height = 324
      height = max_height if footer_size < 2
      height = max_height - (12 * (footer_size - 1)) if footer_size > 1
      bounding_box([0, cursor], width: 232, height: height) do
        contents.each do |content|
          text_formatted content
        end
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
