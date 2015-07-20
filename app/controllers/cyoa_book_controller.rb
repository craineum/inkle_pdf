require 'open-uri'

class CyoaBookController < ApplicationController
  def show
  end

  def create
    @title = parser.title
    @author  = parser.author
    @segments = BookSegments.new.add parser.segments
    @include_title_page = params[:title_page]
    @page_number_image = params[:page_number_image]
    @markup_map = markup_mapper
  end

  private

  def story_id
    @story_id ||= URI(params['inkle_url']).path.split('/').last.split('.').first
  end

  def url
    @url ||= 'https://writer.inklestudios.com/stories/' + story_id + '.json'
  end

  def parser
    @parser ||= ParseInkleService.new(open(url).read)
  end

  def markup_mapper
    MarkupMapperService.new(params).tags_mapping
  end
end
