class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_accessor :marker, :name

  def initialize
    set_name
  end

  def set_marker(marker)
    @marker = marker
  end
end

class Human < Player
  def set_name
    n = nil
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a name."
    end
    self.name = n
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Number 5', 'Sonny', 'C3P0'].sample
  end
end

class TTTGame
  FIRST_TO_MOVE = 'X'
  SECOND_TO_MOVE = 'O'
  WINNING_SCORE = 5

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new
    @computer = Computer.new

    @current_marker = FIRST_TO_MOVE

    @human_wins = 0
    @computer_wins = 0
    @ties = 0
  end

  def play
    clear
    display_welcome_message
    human_choose_marker

    loop do
      display_board

      loop do
        current_player_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board
      end

      display_result
      display_score
      break if won_round?
      break unless play_again?
      reset
      display_play_again_message
    end

    display_goodbye_message
  end

  private

  def human_choose_marker
    choice = nil
    loop do
      puts "Please choose your marker #{human.name}. 'X' or 'O' ('X' goes first)"
      choice = gets.chomp.upcase
      break if ['X', 'O'].include? choice
      puts "Choice must be 'X' or 'O'"
    end
    human.set_marker(choice)
    computer.set_marker(computer_marker)
  end

  def computer_marker
    human.marker == 'X' ? 'O' : 'X'
  end

  def display_score
    puts ""
    puts "Score: #{human.name}: #{@human_wins} / #{computer.name}: #{@computer_wins} / Ties: #{@ties}"
    puts ""
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe! A game of champions."
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing! Goodbye."
  end

  def display_board
    puts "#{human.name} is #{human.marker}. #{computer.name} is #{computer.marker}"
    puts ""
    puts "First to 5 wins, WINS!!!"
    puts ""
    board.draw
    puts ""
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_moves
    puts "Choose a square (#{board.unmarked_keys.join(', ')}):"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry. That's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    board[board.unmarked_keys.sample] = computer.marker
  end

  def current_player_moves
    if @current_marker == human.marker
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "#{human.name} won!"
      @human_wins += 1
    when computer.marker
      puts "#{computer.name} won!"
      @computer_wins += 1
    else
      puts "The board is full!"
      @ties += 1
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be 'y' or 'n'."
    end

    answer == 'y'
  end

  def won_round?
    @human_wins == WINNING_SCORE || @computer_wins == WINNING_SCORE
  end

  def clear
    system 'clear'
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play
