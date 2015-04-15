class CyoaBookService
  attr_accessor :pdf

  def initialize(title='Untitled', author='Unknown')
    @pdf = CyoaBook.new(page_size: [432, 648], margin: [54, 54, 108, 54])
    pdf.text title
    pdf.text "by " + author
    BookSegment.each do |book_segment|
      pdf.start_new_page
      book_segment.page_start = pdf.page_count
      pdf.segment_content(book_segment.contents)
      book_segment.page_end = pdf.page_count

      pdf.footers(book_segment)
    end
  end

  def render
    pdf.render
  end

  private

  class CyoaBook
    include Prawn::View

    def initialize(attributes={})
      @document ||= Prawn::Document.new(attributes)
    end

    def segment_content(contents)
      contents.each do |content|
        text content
      end
    end

    def footers(book_segment)
      this_footer book_segment
      parent_footers book_segment
    end

    def this_footer(book_segment)
      if book_segment.page_start != book_segment.page_end
        footer_next(book_segment.page_start..book_segment.page_end-1)
        go_to_last_page
      end
      footer_end if book_segment.children.blank?
    end

    def parent_footers(book_segment)
      if book_segment.parents.present?
        book_segment.parents.each { |parent| parent_footer parent }
        go_to_last_page
      end
    end

    def parent_footer(parent)
      footers = parent.children.map do |child|
        if child.page_start.present?
          { option: parent.child_option(child.id), page: child.page_start }
        end
      end.compact
      if footers.length == parent.children.length
        footer_options(parent.page_end, footers)
      end
    end

    def footer_end
      footer 'The End'
    end

    def footer_next(page_range)
      (page_range).each do |number|
        go_to_page number
        footer 'Turn to the next page'
      end
    end

    def footer_options(parent_page, footers)
      footers = footers.map do |footer|
        if footer[:option].present?
          footer[:option] + ' - Turn to page ' + footer[:page].to_s
        else
          'Turn to page ' + footer[:page].to_s
        end
      end
      go_to_page parent_page
      footer(*footers)
    end

    def footer(*messages)
      canvas do
        bounding_box([54, 102], width: 324, height: 96) do
          messages.each do |message|
            text message
          end
        end
      end
    end

    def go_to_last_page
      go_to_page page_count
    end
  end
end
