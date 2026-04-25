# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require "open-uri"
require "json"

# 1. Clean in FK-safe order
puts "Cleaning database..."
Bookmark.destroy_all
List.destroy_all
Movie.destroy_all
puts "Database cleaned."

# 2. Define 5 curated lists with 5 movies each
curated = {
  "Pure Laughter" => [
    ["Superbad",                 "Instantly quotable — an absolute riot from start to finish."],
    ["The Grand Budapest Hotel", "Wes Anderson at his most delightfully absurd."],
    ["Game Night",               "Genuinely funny — way better than it has any right to be."],
    ["Knives Out",               "Sharp, witty, and endlessly entertaining."],
    ["The Nice Guys",            "Crowe and Gosling are a hilarious odd-couple duo."],
    ["Anchorman: The Legend of Ron Burgundy", "I'm kind of a big deal. A comedy landmark."],
    ["Step Brothers",            "Brennan and Dale are the most chaotic duo ever."],
    ["Hot Fuzz",                 "Edgar Wright at his most brilliantly absurd."]
  ],
  "Chick Flicks" => [
    ["Titanic",                    "Epic romance — grab the tissues."],
    ["La La Land",                 "Gorgeous, bittersweet, and beautifully shot."],
    ["Crazy Rich Asians",          "Glamorous, fun, and genuinely heartwarming."],
    ["Mamma Mia!",                 "Pure feel-good joy — ABBA bangers included."],
    ["Notting Hill",               "Classic rom-com charm at its best."],
    ["The Notebook",               "The one that broke a million hearts."],
    ["Legally Blonde",             "Elle Woods is an icon and this film proves it."],
    ["10 Things I Hate About You", "Shakespeare never looked this fun."]
  ],
  "Comedy Classics" => [
    ["Forrest Gump",               "Life is like a box of chocolates — timeless."],
    ["The Princess Bride",         "Inconceivable that you haven't seen this."],
    ["Groundhog Day",              "Gets better every rewatch — fittingly enough."],
    ["Mrs. Doubtfire",             "Robin Williams at his most lovable best."],
    ["Home Alone",                 "A comedy classic that never gets old."],
    ["Ferris Bueller's Day Off",   "Life moves pretty fast. Don't miss it."],
    ["Dumb and Dumber",            "Peak slapstick. Carey and Daniels are unhinged."],
    ["My Big Fat Greek Wedding",   "Warm, chaotic, and impossibly charming."]
  ],
  "Action Packed" => [
    ["The Dark Knight",    "The gold standard of superhero films."],
    ["Gladiator",          "Are you not entertained? Absolutely yes."],
    ["Mad Max: Fury Road", "Two hours of relentless, stunning action."],
    ["The Matrix",         "Still mind-blowing — the one that started it all."],
    ["Top Gun: Maverick",  "Bigger, better, and faster than the original."],
    ["John Wick",          "Keanu Reeves at his most unstoppable."],
    ["Die Hard",           "The definitive action film. Yes, it's a Christmas movie."],
    ["Mission: Impossible - Fallout", "Peak Tom Cruise — the HALO jump alone is worth it."]
  ],
  "Mind-Benders" => [
    ["Inception",      "Dreams within dreams — Nolan at his best."],
    ["The Prestige",   "Every scene is a clue — watch it twice."],
    ["Shutter Island", "A masterclass in psychological tension."],
    ["Parasite",       "Unpredictable and utterly gripping."],
    ["Interstellar",   "Ambitious, emotional, and visually stunning."],
    ["Memento",        "Told backwards — and it still makes your head spin."],
    ["Black Swan",     "Portman at her most haunting. Unsettling in the best way."],
    ["Ex Machina",     "Quietly terrifying. AI has never felt this real."]
  ]
}

# 3. Fetch each movie from OMDB by title and create records
api_key = ENV["OMDB_API_KEY"]
movie_map = {} # maps search title -> Movie record

puts "Fetching movies from OMDB..."
all_titles = curated.values.flat_map { |entries| entries.map(&:first) }.uniq

all_titles.each do |title|
  encoded = URI.encode_www_form_component(title)
  url = "http://www.omdbapi.com/?apikey=#{api_key}&t=#{encoded}"
  data = JSON.parse(URI.open(url).read)

  if data["Response"] == "True"
    rt = (data["Ratings"] || []).find { |r| r["Source"] == "Rotten Tomatoes" }&.dig("Value")
    movie = Movie.create(
      title:           data["Title"],
      overview:        data["Plot"],
      poster_url:      data["Poster"] == "N/A" ? nil : data["Poster"],
      rating:          data["imdbRating"] == "N/A" ? 0.0 : data["imdbRating"].to_f,
      year:            data["Year"] == "N/A" ? nil : data["Year"],
      genre:           data["Genre"] == "N/A" ? nil : data["Genre"],
      director:        data["Director"] == "N/A" ? nil : data["Director"],
      actors:          data["Actors"] == "N/A" ? nil : data["Actors"],
      runtime:         data["Runtime"] == "N/A" ? nil : data["Runtime"],
      rotten_tomatoes: rt
    )
    movie_map[title] = movie
    puts "  ✓ #{title}"
  else
    puts "  ⚠ Not found on OMDB: #{title}"
  end
end
puts "Movies created: #{Movie.count}"

# 4. Create lists and bookmarks
puts "Creating lists and bookmarks..."
curated.each do |list_name, entries|
  list = List.find_or_create_by!(name: list_name)
  entries.each do |title, comment|
    movie = movie_map[title]
    if movie
      Bookmark.create!(list: list, movie: movie, comment: comment)
      puts "  ✓ #{list_name} <- #{title}"
    else
      puts "  ⚠ Skipping bookmark: #{title}"
    end
  end
end

puts "\nDone! #{List.count} lists, #{Movie.count} movies, #{Bookmark.count} bookmarks."
