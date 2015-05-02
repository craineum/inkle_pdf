class BookSegments
  include Enumerable

  def initialize
    super
    @segments = []
  end

  def add(segments)
    segments.each do |segment|
      @segments << BookSegment.new(self, segment.to_a)
    end
    self
  end

  def each(&block)
    @segments.each { |item| block.call(item) }
  end

  def valid?
    @segments.all? { |item| item.valid? }
  end
end
