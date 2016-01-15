class Square
  attr_reader :letter
  attr_reader :board_coordinates
  attr_reader :window_coordinates
  attr_reader :size

  def initialize(board_coordinates, window_coordinates, size)
    @board_coordinates = board_coordinates
    @window_coordinates = window_coordinates
    @size = size
    @font = Gosu::Font.new(100)
    @c = Gosu::Color.argb(
      255,
      Gosu.random(0, 255).to_i,
      Gosu.random(0, 255).to_i,
      Gosu.random(0, 255).to_i
    )
  end

  def mark_letter(letter)
    @letter = letter
  end

  def center_point
    @center_point ||= window_coordinates.map {|c| c + size/2}
  end

  def occupied?
    !letter.nil?
  end

  def draw
    # Gosu.draw_rect window_coordinates[0], window_coordinates[1], size, size, @c
    if letter
      @font.draw_rel letter, center_point[0], center_point[1], 0, 0.5, 0.5, 1, 1, Gosu::Color::RED
    end
  end
end

