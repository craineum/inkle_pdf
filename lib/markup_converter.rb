class MarkupConverter
  attr_accessor :maps, :map

  def initialize(maps)
    @maps = maps
  end

  def tags(string)
    maps.inject(string) do |text, map|
      @map = map
      text.gsub(/#{swap_start}(.*?)#{swap_end}/, "#{tag_start}\\1#{tag_end}")
    end
  end

  private

  def swap_start
    map[:from] || map[:from_start]
  end

  def swap_end
    map[:from] || map[:from_end]
  end

  def tag_start
    "<#{map[:to] || map[:to_start]}>"
  end

  def tag_end
    "</#{map[:to] || map[:to_end]}>"
  end
end
