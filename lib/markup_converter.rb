class MarkupConverter
  attr_accessor :maps, :map

  def initialize(maps)
    @maps = maps
  end

  def tags(string)
    maps.inject(string) do |text, map|
      @map = map
      if map.has_key? :from
        text.gsub(/#{swap_void}/, "#{tag_void}")
      else
        text.gsub(/#{swap_start}(.*?)#{swap_end}/, "#{tag_start}\\1#{tag_end}")
      end
    end
  end

  private

  def swap_void
    map[:from]
  end

  def tag_void
    "<#{map[:to]} />"
  end

  def swap_start
    map[:from_start]
  end

  def swap_end
    map[:from_end]
  end

  def tag_start
    "<#{map[:to]}>"
  end

  def tag_end
    "</#{map[:to]}>"
  end
end
