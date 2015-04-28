prawn_document({ renderer: CyoaBookHelper::CyoaBookPdf,
                 markup_converter: MarkupConverter,
                 page_size: [432, 648],
                 margin: [54, 54, 108, 54] }) do |pdf|
  pdf.text @title
  pdf.text "by " + @author
  @segments.each do |segment|
    pdf.start_new_page
    segment.page_start = pdf.page_count
    pdf.segment_contents(segment.contents)
    segment.page_end = pdf.page_count

    segment.footers.each do |footer|
      pdf.go_to_page footer[:page]
      pdf.footer footer[:footers]
    end if segment.footers?
    pdf.go_to_last_page
  end
  pdf.page_numbers
end
