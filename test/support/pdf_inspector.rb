module PdfInspector
  def assert_pdf_has_content?(text)
    assert text_analysis.strings.include?(text), content_message(text)
  end

  def assert_pdf_page_count(count)
    assert pdf_page_count == count, page_count_message(count)
  end

  private

  def content_message(expected)
    "PDF does not contain #{expected}"
  end

  def page_count_message(expected)
    "PDF has #{pdf_page_count}, not #{expected} page(s)"
  end

  def pdf_page_count
    page_analysis.pages.size
  end

  def text_analysis
    @text_analysis ||= PDF::Inspector::Text.analyze(page.source)
  end

  def page_analysis
    @page_analysis ||= PDF::Inspector::Page.analyze(page.source)
  end

end
