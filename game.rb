require 'gosu'
require 'hasu'

Hasu.load("square.rb")
Hasu.load("board.rb")

class Game < Hasu::Window
  Z_FRONT ||= 100

  def initialize
    super 600, 600
    self.caption = "Tic Tac Toe"
  end

  def reset
    @state = :new_game
    @board = Board.new(width, height)
    @cursor = Gosu::Image.new('cursor.png',tileable=false)
    @current_letter = "X"
  end

  def update
  end

  def button_down(id)
    case id
    when Gosu::KbEscape
      close
    when Gosu::MsLeft
      process_click
    end
  end

  def start_game
    @winner = nil
    @board.clear
    @state = :playing
  end

  def process_click
    case @state
    when :new_game, :cats_game, :winner
      start_game
    when :playing
      if @board.mark_letter @current_letter, mouse_x, mouse_y
        check_win? || full_board?
        swap_letter
      end
    end
  end

  def check_win?
    if @board.check_win?
      @state = :winner
      @winner = @current_letter
    end
  end

  def full_board?
    if @board.full?
      @state = :cats_game
    end
  end

  def swap_letter
    @current_letter = case @current_letter
      when "X" then "O"
      else "X"
    end
  end

  def draw
    Gosu.draw_rect 0, 0, width, height, Gosu::Color::WHITE
    @board.draw
    draw_overlay unless @state == :playing

    @cursor.draw mouse_x, mouse_y, Z_FRONT, 0.5, 0.5

    case @state
    when :new_game
      font = Gosu::Font.new(25)
      font.draw_text_rel("Click to start a new game", width/2, height/2, 0, 0.5, 0.5, 1, 1,  Gosu::Color::RED)
    when :winner
      font = Gosu::Font.new(40)
      font.draw_text_rel("#{@winner} is the WINNER!!!!!", width / 2, height / 2, 0, 0.5, 0.5, 1, 1, Gosu::Color::GREEN)
    when :cats_game
      font = Gosu::Font.new(40)
      font.draw_text_rel("CAT'S GAME :(", width / 2, height / 2, 0, 0.5, 0.5, 1, 1, Gosu::Color::BLUE)
    when :playing
    end
  end

  def draw_overlay
    Gosu.draw_rect 0, 0, width, height, Gosu::Color.argb(0xdd_ffffff)
  end

end

Game.run
