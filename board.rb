class Board
  attr_reader :margin

  WIN_CONDITIONS ||= [
    [ [0,0], [1,0], [2,0] ], # top row
    [ [0,1], [1,1], [2,1] ], # middle row
    [ [0,2], [1,2], [2,2] ], # bottom row
    [ [0,0], [0,1], [0,2] ], # left column
    [ [1,0], [1,1], [1,2] ], # middle column
    [ [2,0], [2,1], [2,2] ], # right column
    [ [0,0], [1,1], [2,2] ], # diagonal top left
    [ [2,0], [1,1], [0,2] ], # diagonal bottom left
  ]

  def initialize(w, h)
    @w = w
    @h = h
    @margin = 40
    @color = Gosu::Color.argb(0xff_666666)
    @font = Gosu::Font.new(100)
    clear
  end

  def draw
    draw_grid
    @squares.each(&:draw)
    draw_winning_strike
  end

  def draw_winning_strike
    return unless @strike_points
    x1, y1, x2, y2 = @strike_points
    if x1 && x2 && y1 && y2
      c = Gosu::Color::RED
      Gosu.draw_line x1, y1, c, x2, y2, c
    end
  end

  def check_win?
    winning_squares = WIN_CONDITIONS.select {|wc|
      squares = wc.map {|coords| square_at(*coords)}
      letters = squares.map(&:letter)
      !letters.any?(&:nil?) && letters.uniq.length == 1
    }.first

    if winning_squares
      squares = winning_squares.map {|c| square_at(*c) }
      @strike_points = [
        squares.first.center_point,
        squares.last.center_point
      ].flatten
      true
    else
      false
    end
  end

  def full?
    @squares.all?(&:occupied?)
  end

  def draw_grid
    x1 = middle_box_x
    x2 = right_box_x
    y1 = middle_box_y
    y2 = bottom_box_y

    Gosu.draw_line x1, top, @color, x1, bottom, @color
    Gosu.draw_line x2, top, @color, x2, bottom, @color
    Gosu.draw_line left, y1, @color, right, y1, @color
    Gosu.draw_line left, y2, @color, right, y2, @color
  end

  def square_size
    (@w - @margin * 2) / 3
  end

  def left_box_x
    @margin
  end

  def middle_box_x
    square_at(1, 0).window_coordinates[0]
  end

  def right_box_x
    square_at(2, 0).window_coordinates[0]
  end

  def top_box_y
    @margin
  end

  def middle_box_y
    square_at(0, 1).window_coordinates[1]
  end

  def bottom_box_y
    square_at(0, 2).window_coordinates[1]
  end

  def clear
    @squares = generate_board
    @strike_points = nil
  end

  def generate_board
    9.times.map do |i|
      bx = i % 3
      by = i.div(3)
      wx = bx * square_size + margin
      wy = by * square_size + margin
      Square.new([bx, by], [wx, wy], square_size)
    end
  end

  def coords_from_point(x, y)
    pct_across_x = x/@w
    cx = case
              when pct_across_x < 0.3 then 0
              when pct_across_x > 0.6 then 2
              else 1
              end

    pct_across_y = y / @h
    cy = case
              when pct_across_y < 0.3 then 0
              when pct_across_y > 0.6 then 2
              else 1
              end
    [cx, cy]
  end

  def mark_letter(letter, x, y)
    coords = coords_from_point(x, y)
    cx = coords[0]
    cy = coords[1]
    sq = square_at(cx, cy)
    sq.mark_letter(letter) unless sq.occupied?
  end

  def square_at(x, y)
    @squares.select {|s| s.board_coordinates == [x,y]}.first
  end

  def left
    @margin
  end

  def top
    @margin
  end

  def bottom
    @h - @margin
  end

  def right
    @w - @margin
  end
end

