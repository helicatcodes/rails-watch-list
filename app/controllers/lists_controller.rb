class ListsController < ApplicationController
  # before_action is a Rails hook that runs a method BEFORE specified actions.
  # Here, set_list runs before show and destroy so that @list is always
  # available in those actions without repeating List.find(params[:id]) each time.
  before_action :set_list, only: [ :show, :destroy ]

  # GET /lists — shows all lists
  def index
    # List.all fetches every row from the lists table and stores them
    # in @list so the view can loop over them with @lists.each do |list|
    @lists = List.all
  end

  # GET /lists/:id — shows one list and its bookmarked movies
  def show
    # @list is already set by set_list (see private section below).
    # We prepare a blank Bookmark so the "add movie" form on this page
    # has an object to bind to. We'll wire this up when we build bookmarks.
    @bookmark = Bookmark.new
  end

  # GET /lists/new — shows the form for creating a new list
  def new
    # A blank List object is needed by simple_form_for in the view
    # so it knows what model the form is for and where to submit it.
    @list = List.new
  end

  # POST /lists — handles form submission from the new page
  def create
    @list = List.new(list_params)
    if @list.save
      # Saved successfully — send the user to that list's page.
      redirect_to list_path(@list)
    else
      # Validation failed — re-render the form with error messages.
      # status: :unprocessable_entity tells the browser this was a 422 error,
      # which is important for Turbo (Rails' front-end framework) to work correctly.
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /lists/:id — deletes a list and all its bookmarks (see model)
  def destroy
    @list.destroy
    # status: :see_other (303) is needed because browsers expect a redirect
    # after a DELETE request, and Turbo requires 303 specifically.
    redirect_to lists_path, status: :see_other
  end

  private

  # Private methods can only be called from inside this controller,
  # not triggered directly by a route. This keeps internal logic separate.

  def set_list
    # params[:id] comes from the URL — e.g. /lists/3 gives params[:id] == "3"
    # find() looks up a record by its primary key (id). Raises ActiveRecord::RecordNotFound
    # (404 page) if no record exists with that id.
    @list = List.find(params[:id])
  end

  def list_params
    # Strong parameters: we require the :list key and only allow :name through.
    # This prevents attackers from sneaking extra fields into the form submission.
    params.require(:list).permit(:name)
  end
end
