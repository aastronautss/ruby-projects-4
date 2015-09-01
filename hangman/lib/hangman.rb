require 'yaml'

module Hangman
  class Board
    attr_reader :word_list, :letters, :fill_in, :wrong_guesses

    def initialize(filename = '5desk.txt')
      @word_list = valid_words(filename)
    end

    def play(guesses = 6)
      @letters = randomize.split('')
      @fill_in = Array.new(letters.length, '_')
      @wrong_guesses = []

      while guesses > 0
        display_board(guesses)
        guess = solicit_guess

        save_game if guess == 'save'

        if @letters.include? guess
          @letters.each_with_index do |letter, index|
            if guess == letter
              @fill_in[index] = guess
            end
          end
        else
          @wrong_guesses << guess
          guesses -= 1
        end

        if @fill_in == @letters
          display_board(guesses)
          return "Player wins! The word is \"#{@letters.join('')}!\""
        end
      end
      "You have been hanged! The word was \"#{@letters.join('')}!\""
    end

    private

    def valid_words(filename, min_length = 5, max_length = 12)
      words = File.readlines(filename).select do |word|
        word.chomp.length >= min_length && word.chomp.length <= max_length
      end

      words.map { |word| word.chomp.downcase }
    end

    def randomize
      @word_list[rand(@word_list.length)]
    end

    def display_board(guesses_left = 0)
      puts "\nYou have #{guesses_left} incorrect guesses left!\n\n"
      puts @fill_in.join('  ')
      puts "\nMisses: #{@wrong_guesses.join(' ')}"
    end

    def solicit_guess
      loop do
        print "Enter your guess, or type \"save\" to save and exit: "
        guess = gets.chomp.downcase
        return guess if valid_guess?(guess)
        puts 'Invalid input!'
      end
    end

    def valid_guess?(guess)
      (!@fill_in.include?(guess) && !@wrong_guesses.include?(guess) && guess.length == 1) || guess == 'save'
    end

    def save_game
      yam = YAML::dump(self)
      filename = "saves/s_#{Time.new.strftime('%Y%m%d%H%M%S')}.yaml"
      File.open(filename, 'w') do |f|
        f.puts yam
      end
      puts "Saved as #{filename} !"
      exit
    end
  end


  def load_game
    filename = "saves/#{prompt_filename}"
    content = File.read(filename)
    YAML::load(content)
  end

  def prompt_filename
    save_arr = Dir[saves]
    save_arr.each_with_index do |save, index|
      puts "(#{index + 1}) #{save}"
    end

    loop do
      print 'Enter the number corresponding to the desired save: '
      choice = gets.chomp.to_i - 1
      return save_arr[choice ] unless save_arr[choice].nil?
      puts 'Invalid input!'
    end
  end
end
game = Hangman::Board.new
puts game.play