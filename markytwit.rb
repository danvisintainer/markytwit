require 'marky_markov'
require 'twitter'
require 'pry'

twitter = Twitter::REST::Client.new do |config|
  config.consumer_key = "y7XvS1rJ9Tul1Q1oQaW6Ks1qb"
  config.consumer_secret = "RWEQSv8YYBMrolPQpj5GH9dEzv4Ka9aG9dp9sOIdz67FPkFOMM"
end

timeline = twitter.user_timeline("dviz", {count: 200})
timeline << twitter.user_timeline("dviz", {count: 200, max_id: (timeline.last.id - 1)})
timeline.flatten!
timeline << twitter.user_timeline("dviz", {count: 200, max_id: (timeline.last.id - 1)})
timeline.flatten!

string = timeline.collect do |t|
  next if t.full_text.include?("RT ") || t.full_text.include?("\#lastfm")

  s = t.full_text.split.delete_if do |s|
    s.include?("http") || s.include?("\#") || s.include?("@")
  end

  s.each { |word| word.slice!("\"")}
  s.last << "." unless s.empty? || s.last[-1] == "." || s.last[-1] == "?" || s.last[-1] == "!"
  s
end.join(" ")

markov = MarkyMarkov::TemporaryDictionary.new
markov.parse_string string
# puts markov.generate_n_sentences 5
# puts markov.generate_n_words 200

binding.pry

markov.clear!