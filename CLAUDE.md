# rails-watch-list

Movie watchlist manager. Users create named lists and bookmark movies to them with a comment. Movie data (title, overview, poster, rating) is fetched from the OMDB API — not static fixtures. Status: work in progress.

## Tech Stack

- Rails 8.1 / Ruby 3.3.5
- PostgreSQL
- Hotwire — Turbo + Stimulus, no webpack, import maps only
- Bootstrap 5 + Font Awesome 6 + custom SCSS (sassc-rails)
- SimpleForm for forms
- RSpec for testing (models, controllers, requests, routing)
- dotenv-rails for environment variables
- Kamal + Docker for deployment

## Key Models

- `Movie` — title, overview, poster_url, rating; `has_many :bookmarks`
- `List` — name; `has_many :bookmarks, dependent: :destroy`
- `Bookmark` — join table (list + movie + comment); comment must be ≥ 6 chars; movie must be unique per list

## Routes

Routes are manually defined — do not convert to `resources`. Current routes:

```
GET  /lists        lists#index
GET  /lists/new    lists#new
POST /lists        lists#create
GET  /lists/:id    lists#show
POST /bookmarks    bookmarks#create
```

## Development Commands

```
bin/rails server          # start dev server
bin/rails db:seed         # seed with OMDB-fetched movies (requires OMDB_API_KEY)
bundle exec rspec         # run full test suite
bundle exec rubocop       # lint
bundle exec brakeman      # security scan
```

## Environment Variables

- `OMDB_API_KEY` — required for seeds and any movie search functionality

## Collaboration Preferences

- Keep responses short and concise — no trailing summaries of what was just done
- No comments in code unless the why is genuinely non-obvious
- Don't add features, abstractions, or error handling beyond what's explicitly asked
- No emojis unless explicitly requested
- For UI changes: always test in the browser before marking done; if unable to test, say so explicitly
