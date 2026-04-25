class AddDetailsToMovies < ActiveRecord::Migration[8.1]
  def change
    add_column :movies, :year, :string
    add_column :movies, :genre, :string
    add_column :movies, :director, :string
    add_column :movies, :actors, :string
    add_column :movies, :runtime, :string
    add_column :movies, :rotten_tomatoes, :string
  end
end
