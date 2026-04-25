require "open-uri"
require "json"

class MoviesController < ApplicationController
  def search
    q = params[:q].to_s.strip
    return render json: [] if q.length < 2

    render json: omdb_search(q)
  rescue StandardError
    render json: []
  end

  def select
    imdb_id = params[:imdb_id].to_s.strip
    return render json: { error: "Missing imdb_id" }, status: :bad_request if imdb_id.blank?

    movie = find_or_create_from_omdb(imdb_id)
    if movie&.persisted?
      render json: { id: movie.id, title: movie.title }
    else
      render json: { error: "Could not create movie" }, status: :unprocessable_entity
    end
  rescue StandardError
    render json: { error: "Something went wrong" }, status: :internal_server_error
  end

  private

  def omdb_search(query)
    url = "https://www.omdbapi.com/?apikey=#{ENV['OMDB_API_KEY']}&s=#{URI.encode_www_form_component(query)}&type=movie"
    data = JSON.parse(URI.open(url).read)
    return [] unless data["Response"] == "True"

    data["Search"].map do |m|
      {
        title:   m["Title"],
        year:    m["Year"],
        poster:  m["Poster"] == "N/A" ? nil : m["Poster"],
        imdb_id: m["imdbID"]
      }
    end
  end

  def find_or_create_from_omdb(imdb_id)
    url = "https://www.omdbapi.com/?apikey=#{ENV['OMDB_API_KEY']}&i=#{imdb_id}"
    data = JSON.parse(URI.open(url).read)
    return nil unless data["Response"] == "True"

    rt = (data["Ratings"] || []).find { |r| r["Source"] == "Rotten Tomatoes" }&.dig("Value")

    movie = Movie.find_or_create_by(title: data["Title"]) do |m|
      m.overview   = data["Plot"]
      m.poster_url = data["Poster"] == "N/A" ? nil : data["Poster"]
      m.rating     = data["imdbRating"] == "N/A" ? 0.0 : data["imdbRating"].to_f
    end

    movie.update_columns(
      year:            data["Year"] == "N/A" ? nil : data["Year"],
      genre:           data["Genre"] == "N/A" ? nil : data["Genre"],
      director:        data["Director"] == "N/A" ? nil : data["Director"],
      actors:          data["Actors"] == "N/A" ? nil : data["Actors"],
      runtime:         data["Runtime"] == "N/A" ? nil : data["Runtime"],
      rotten_tomatoes: rt
    )

    movie
  end
end
