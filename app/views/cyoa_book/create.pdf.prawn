prawn_document({ renderer: CyoaBookHelper::CyoaBookPdf,
                 skip_page_creation: true,
                 markup_converter: MarkupConverter,
                 markup_map: @markup_map,
                 page_size: [306, 396],
                 margin: [36, 36, 36, 36] }) do |pdf|
  if @include_title_page
    pdf.start_new_page
    pdf.move_down 115
    pdf.text @title, align: :center, size: 18, style: :bold
    pdf.move_down 10
    pdf.text "by " + @author, align: :center, size: 14
  end
  @segments.each do |segment|
    pdf.start_new_page
    segment.page_start = pdf.page_count
    pdf.segment_contents(segment.contents, segment.child_ids.size)
    segment.page_end = pdf.page_count

    segment.footers.each do |footer|
      pdf.go_to_page footer[:page]
      pdf.footer footer[:footers]
    end if segment.footers?
    pdf.go_to_last_page
  end
  pdf.page_numbers
end
