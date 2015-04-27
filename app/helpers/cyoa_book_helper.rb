module CyoaBookHelper
  class CyoaBookPdf
    include Prawn::View

    def initialize(attributes={})
      @document ||= Prawn::Document.new(attributes)
      @pages_with_footer = []
    end

    def footer(messages)
      if @pages_with_footer.exclude? page_number
        @pages_with_footer << page_number
        canvas do
          bounding_box([54, 102], width: 324, height: 96) do
            messages.each do |message|
              text message
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
        size: 24
      }
      even_options = {
        at: [bounds.left - 48, bounds.top + 36],
        width: 42,
        align: :center,
        page_filter: :even,
        start_count_at: 2,
        size: 24
      }
      number_pages page, odd_options
      number_pages page, even_options
    end

    def segment_contents(contents)
      contents.each do |content|
        text content, indent_paragraphs: 20
      end
    end
  end
end
