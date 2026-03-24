# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# # MANUAL SEED CREATION
# # 1 Clean the database
# puts "Cleaning database..."
# Movie.destroy_all

# # 2 Create instances
# puts "Creating movies"

# Movie.create(title: "Wonder Woman 1984", overview: "Wonder Woman comes into conflict with the Soviet Union during the Cold War in the 1980s", poster_url: "https://image.tmdb.org/t/p/original/8UlWHLMpgZm9bx6QYh0NFoq67TZ.jpg", rating: 6.9)
# Movie.create(title: "The Shawshank Redemption", overview: "Framed in the 1940s for double murder, upstanding banker Andy Dufresne begins a new life at the Shawshank prison", poster_url: "https://image.tmdb.org/t/p/original/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg", rating: 8.7)
# Movie.create(title: "Titanic", overview: "101-year-old Rose DeWitt Bukater tells the story of her life aboard the Titanic.", poster_url: "https://image.tmdb.org/t/p/original/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg", rating: 7.9)
# Movie.create(title: "Ocean's Eight", overview: "Debbie Ocean, a criminal mastermind, gathers a crew of female thieves to pull off the heist of the century.", poster_url: "https://image.tmdb.org/t/p/original/MvYpKlpFukTivnlBhizGbkAe3v.jpg", rating: 7.0)

# # 3 Display a message

# puts "Finished! Created #{Movie.count} movies."

# USING FAKER GEM

# puts "Cleaning database..."
# Movie.destroy_all

# puts "Creating movies"

# 10.times do
#   Movie.create(
#     title: Faker::Movie.title,
#     overview: Faker::Lorem.paragraph(sentence_count: 3),
#     poster_url: "https://via.placeholder.com/300x450.png?text=#{Faker::Movie.title.gsub(' ', '+')}",
#     rating: rand(1.0..10.0).round(1)
#   )
# end

# puts "Finished! Created #{Movie.count} movies."


# USING AN API

require "open-uri"
require "json"

puts "Cleaning up database..."
Movie.destroy_all
puts "Database cleaned"

url = "http://tmdb.lewagon.com/movie/top_rated"
10.times do |i|
  puts "Importing movies from page #{i + 1}"
  movies = JSON.parse(URI.open("#{url}?page=#{i + 1}").read)["results"]
  movies.each do |movie|
    puts "Creating #{movie["title"]}"
    base_poster_url = "https://image.tmdb.org/t/p/original"
    Movie.create(
      title: movie["title"],
      overview: movie["overview"],
      poster_url: "#{base_poster_url}#{movie["poster_path"]}",
      rating: movie["vote_average"]
    )
  end
end
puts "Movies created"

# SEEDING SOME LISTS

puts "Seeding some example lists"
List.create(name: "Top Movies")
List.create(name: "Family Movies")
List.create(name: "Action Hits")

puts "Lists created"
