require 'byebug'
class Board
  attr_reader :letters
  attr_reader :margin

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
    draw_letters
    draw_winning_strike
  end

  def compute_winning_strike_coords
    msq = square_size / 2
    x1 = nil
    x2 = nil
    y1 = nil
    y2 = nil

    # rows
    if is_match?(rows[0])
      x1 = left_box_x + margin
      y1 = top_box_y + msq
      x2 = right_box_x + square_size - margin
      y2 = y1
    end

    if is_match?(rows[1])
      x1 = left_box_x + margin
      y1 = middle_box_y + msq
      x2 = right_box_x + square_size - margin
      y2 = y1
    end

    if is_match?(rows[2])
      x1 = left_box_x + margin
      y1 = bottom_box_y + msq
      x2 = right_box_x + square_size - margin
      y2 = y1
    end

    # cols
    if is_match?(columns[0])
      x1 = left_box_x + msq
      y1 = top_box_y + margin
      x2 = x1
      y2 = bottom_box_y + square_size - margin
    end

    if is_match?(columns[1])
      x1 = middle_box_x + msq
      y1 = top_box_y + margin
      x2 = x1
      y2 = bottom_box_y + square_size - margin
    end

    if is_match?(columns[2])
      x1 = right_box_x + msq
      y1 = top_box_y + margin
      x2 = x1
      y2 = bottom_box_y + square_size - margin
    end

    if is_match?(diagonal1)
      x1 = left_box_x + msq - margin*2
      y1 = top_box_y + msq - margin*2
      x2 = right_box_x + msq + margin*2
      y2 = bottom_box_y + msq + margin*2
    end

    if is_match?(diagonal2)
      x1 = right_box_x + msq + margin*2
      y1 = top_box_y + msq - margin*2
      x2 = left_box_x + msq - margin*2
      y2 = bottom_box_y + msq + margin*2
    end

    if x1 && y1 && x2 && y2
      @strike_points = [x1, y1, x2, y2]
    end
  end

  def draw_winning_strike
    return unless @strike_points
    x1, y1, x2, y2 = @strike_points
    if x1 && x2 && y1 && y2
      c = Gosu::Color::RED
      Gosu.draw_line x1, y1, c, x2, y2, c
    end
  end

  def is_match?(group)
    return false if group.length < 3
    return false if group.length != group.compact.length
    group.all? {|g| g == group.first }
  end

  def rows
    @letters
  end

  def columns
    @letters.transpose
  end

  def diagonal1
    d = []
    @letters.count.times do |i|
      d << @letters[i][i]
    end
    d
  end

  def diagonal2
    d = []
    @letters.count.times do |i|
      d << @letters[@letters.count-1-i][i]
    end
    d
  end

  def check_win?
    is_win = rows.any? {|r| is_match?(r)} ||
      columns.any? {|c| is_match?(c)} ||
      is_match?(diagonal1) ||
      is_match?(diagonal2)

    if is_win
      compute_winning_strike_coords
    end
  end

  def full?
    @letters.flatten.length == @letters.flatten.compact.length
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
    @w / 3 - @margin / 2
  end

  def left_box_x
    @margin
  end

  def middle_box_x
    @w / 2 - square_size / 2
  end

  def right_box_x
    middle_box_x + square_size
  end

  def top_box_y
    @margin
  end

  def middle_box_y
    @h / 2 - square_size / 2
  end

  def bottom_box_y
    middle_box_y + square_size
  end

  def compute_center_coords
    msq = square_size / 2
    [
      [
        [left_box_x + msq, top_box_y + msq],
        [middle_box_x + msq, top_box_y + msq],
        [right_box_x + msq, top_box_y + msq]
      ],
      [
        [left_box_x + msq, middle_box_y + msq],
        [middle_box_x + msq, middle_box_y + msq],
        [right_box_x + msq, middle_box_y + msq]
      ],
      [
        [left_box_x + msq, bottom_box_y + msq],
        [middle_box_x + msq, bottom_box_y + msq],
        [right_box_x + msq, bottom_box_y + msq]
      ]
    ]
  end

  def draw_letters
    centers = compute_center_coords
    @letters.each_with_index do |y_row, y|
      y_row.each_with_index do |letter, x|
        next unless letter
        letter_pos = centers[y][x]
        @font.draw_rel letter, letter_pos[0], letter_pos[1], 0, 0.5, 0.5, 1, 1, Gosu::Color::RED
      end
    end
  end

  def clear
    @strike_points = nil
    @letters = [
      [nil, nil, nil],
      [nil, nil, nil],
      [nil, nil, nil]
    ]
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

  def empty?(x, y)
    coords = coords_from_point(x, y)
    cx = coords[0]
    cy = coords[1]
    letter[cy][cx].nil?
  end

  def mark_letter(letter, x, y)
    coords = coords_from_point(x, y)
    cx = coords[0]
    cy = coords[1]
    @letters[cy][cx] = letter
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
