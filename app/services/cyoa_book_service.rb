class CyoaBookService

  def initialize
    @pdf = Prawn::Document.new(page_size: [432, 648]) do
      BookSegment.each do |book_segment|
        book_segment.page_start = page_count
        book_segment.contents.each do |content|
          text content
        end
        book_segment.page_end = page_count
      end
    end


  end

  def render
    @pdf.render
  end
end
