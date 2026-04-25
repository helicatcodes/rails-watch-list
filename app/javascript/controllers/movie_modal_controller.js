import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "modal", "poster", "title", "rating", "rt",
    "year", "runtime", "genre", "director", "actors",
    "overview", "comment"
  ]

  open(event) {
    if (event.target.closest(".delete-movie-wrap")) return

    const card = event.currentTarget

    const poster = card.dataset.moviePoster
    this.posterTarget.src = poster || ""
    this.posterTarget.style.display = poster ? "block" : "none"

    this.titleTarget.textContent = card.dataset.movieTitle

    this.ratingTarget.innerHTML = `<i class="fa-solid fa-star"></i> ${card.dataset.movieRating}`

    const rt = card.dataset.movieRt
    this.rtTarget.textContent = rt ? `🍅 ${rt}` : ""
    this.rtTarget.style.display = rt ? "inline" : "none"

    this._set(this.yearTarget,     card.dataset.movieYear)
    this._set(this.runtimeTarget,  card.dataset.movieRuntime)
    this._set(this.genreTarget,    card.dataset.movieGenre,    "Genre: ")
    this._set(this.directorTarget, card.dataset.movieDirector, "Director: ")
    this._set(this.actorsTarget,   card.dataset.movieActors,   "Cast: ")
    this._set(this.overviewTarget, card.dataset.movieOverview)
    this._set(this.commentTarget,  card.dataset.movieComment)

    bootstrap.Modal.getOrCreateInstance(this.modalTarget).show()
  }

  _set(el, value, prefix = "") {
    if (value && value !== "undefined") {
      el.textContent = prefix + value
      el.style.display = ""
    } else {
      el.textContent = ""
      el.style.display = "none"
    }
  }
}
