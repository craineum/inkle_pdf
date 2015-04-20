require 'open-uri'

class CyoaBookController < ApplicationController
  def show
  end

  def create
    story_id = URI(params['inkle_url']).path.split('/').last.split('.').first
    send_data generate_pdf(story_id),
      :filename => 'output.pdf',
      :type => 'application/pdf'
  end

  private
  def generate_pdf(story_id)
    url = 'https://writer.inklestudios.com/stories/' + story_id + '.json'
    parser = ParseInkleService.new(open(url).read)
    BookSegment.add(parser.segments)
    CyoaBookService.new(parser.title, parser.author).render
  end
end
