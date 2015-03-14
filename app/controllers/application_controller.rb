class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = CONSUMER_KEY
      config.consumer_secret = CONSUMER_SECRET
    end
  end

  def fetch_timeline(client, username)
    timeline = client.user_timeline(username, {count: 200})
    timeline << client.user_timeline(username, {count: 200, max_id: (timeline.last.id - 1)})
    timeline.flatten!
    timeline << client.user_timeline(username, {count: 200, max_id: (timeline.last.id - 1)})
    timeline.flatten!
  end

  def create_string(timeline)
    timeline.collect do |t|
      next if t.full_text.include?("RT ") || t.full_text.include?("\#lastfm")

      s = t.full_text.split.delete_if do |s|
        s.include?("http") || s.include?("\#") || s.include?("@")
      end

      s.each { |word| word.slice!("\"")}
      s.last << "." unless s.empty? || s.last[-1] == "." || s.last[-1] == "?" || s.last[-1] == "!"
      s
    end.join(" ")
  end

  def return_markov(username)
    markov = MarkyMarkov::TemporaryDictionary.new
    markov.parse_string(create_string(fetch_timeline(client, username)))
    result = markov.generate_2_sentences
    markov.clear!
    result
  end
end
