module PdfInspector
  attr_accessor :pdf

  def assert_pdf_has_content?(pdf, text, options={})
    count = options[:count].present? ? options[:count] : 1
    @pdf ||= pdf
    assert((text_analysis.strings.join(' ').scan(text).count == count),
      "PDF does not contain #{text}")
  end

  def assert_pdf_has_no_content?(pdf, text)
    @pdf ||= pdf
    assert text_analysis.strings.join(' ').exclude?(text),
      "PDF contains #{text} and it should not"
  end

  def assert_pdf_page_count(pdf, count)
    @pdf ||= pdf
    assert pdf_page_count == count,
      "PDF has #{pdf_page_count}, not #{count} page(s)"
  end

  private

  def pdf_page_count
    page_analysis.pages.size
  end

  def text_analysis
    @text_analysis ||= PDF::Inspector::Text.analyze pdf
  end

  def page_analysis
    @page_analysis ||= PDF::Inspector::Page.analyze pdf
  end

end
