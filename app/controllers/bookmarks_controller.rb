class BookmarksController < ApplicationController
  def create
    @bookmark = Bookmark.new(bookmark_params)
    if @bookmark.save
      redirect_to list_path(@bookmark.list), notice: "Movie added to list!"
    else
      redirect_to list_path(@bookmark.list), alert: @bookmark.errors.full_messages.to_sentence
    end
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:movie_id, :list_id, :comment)
  end
end
