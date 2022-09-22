require 'open-uri'
require 'json'

# Controller for find longest word
class GamesController < ApplicationController
  def new
    @random_letter = Array.new(10) { ('A'..'Z').to_a[rand(26)] }
    @start_time = Time.now
  end

  def score
    @word = params[:word]
    @grid = params[:grid]
    start_time = Time.parse(params[:start_time])
    end_time = Time.now

    @result = calculate_score(@word, @grid, start_time, end_time)
  end

  private

  def calculate_score(word, grid, start_time, end_time)
    result = { time: end_time - start_time }
    result[:translation] = verify_word(word)
    result[:score], result[:message] = score_message(word, result[:translation], grid, result[:time])

    result
  end

  def score_message(word, verification, grid, time_taken)
    if verification == true && valid_word?(word, grid) == true
      score = time_taken > 90.0 ? 0 : word.size * (2 - time_taken / 60.0)
      [score, 'Congratulations!']
    elsif valid_word?(word, grid) == false
      [0, "Sorry but #{word} cam't be built out of #{grid}"]
    elsif valid_word?(word, grid) && verification == false
      [0, "Sorry but #{word} does not seem to be a valid English word"]
    end
  end

  def valid_word?(word, grid)
    word.upcase.split('').all? { |letter| grid.include? letter }
  end

  def verify_word(word)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{word.downcase}")
    json = JSON.parse(response.read)
    json['found']
  end
end
