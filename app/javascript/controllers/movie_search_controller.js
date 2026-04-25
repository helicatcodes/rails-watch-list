import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "movieId"]

  connect() {
    this._timer = null
    this._onOutsideClick = this._onOutsideClick.bind(this)
    document.addEventListener("click", this._onOutsideClick)
  }

  disconnect() {
    clearTimeout(this._timer)
    document.removeEventListener("click", this._onOutsideClick)
  }

  search() {
    clearTimeout(this._timer)
    const q = this.inputTarget.value.trim()

    if (q.length < 2) {
      this._clearResults()
      return
    }

    this._timer = setTimeout(() => {
      fetch(`/movies/search?q=${encodeURIComponent(q)}`)
        .then(r => r.json())
        .then(movies => this._renderResults(movies))
        .catch(() => this._clearResults())
    }, 300)
  }

  _renderResults(movies) {
    this.resultsTarget.innerHTML = ""

    if (movies.length === 0) {
      this.resultsTarget.innerHTML = '<div class="search-no-results">No results found</div>'
      return
    }

    movies.forEach(movie => {
      const item = document.createElement("div")
      item.className = "search-result-item"
      item.innerHTML = `
        ${movie.poster
          ? `<img src="${movie.poster}" alt="">`
          : '<div class="search-no-poster"></div>'}
        <span>${movie.title} <small>(${movie.year})</small></span>
      `
      item.addEventListener("click", () => this._selectMovie(movie))
      this.resultsTarget.appendChild(item)
    })
  }

  _selectMovie(movie) {
    this.inputTarget.value = `${movie.title} (${movie.year})`
    this.movieIdTarget.value = ""
    this._clearResults()

    fetch("/movies/select", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ imdb_id: movie.imdb_id })
    })
      .then(r => r.json())
      .then(data => {
        if (data.id) {
          this.movieIdTarget.value = data.id
          this.inputTarget.value = data.title
        }
      })
      .catch(() => {
        this.inputTarget.value = ""
        this.movieIdTarget.value = ""
      })
  }

  _clearResults() {
    this.resultsTarget.innerHTML = ""
  }

  _onOutsideClick(e) {
    if (!this.element.contains(e.target)) this._clearResults()
  }
}
