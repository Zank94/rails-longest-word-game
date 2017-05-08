class GamingController < ApplicationController
  def game
    @grid = generate_grid(10)
    @start_time = Time.now
  end

  def score
    @end_time = Time.now
    @word = params[:word]
    @time_taken =  (@end_time - Time.parse(params[:start_time])).round(2)
    @translation = get_translation(@word)
    @score = compute_score(@word, @time_taken).round(2)
    @message = score_and_message(@word, @translation, params[:grid], @time_taken)
    if session[:attempts]
      session[:attempts] += 1
    else
      session[:attempts] = 1
    end
    if session[:score]
      session[:score] += @score
    else
      session[:score] = @score
    end
    @average_score = session[:score] / session[:attempts]
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def included?(guess, grid)
    guess.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt.upcase.split, grid)
      if translation
        score = compute_score(attempt, time).round(2)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def get_translation(word)
    api_key = "1be78987-e3f7-4588-a5d4-a251277017c4"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
        return word
      else
        return nil
      end
    end
  end
end
