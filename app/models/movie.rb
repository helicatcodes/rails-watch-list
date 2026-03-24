class Movie < ApplicationRecord
    has_many :bookmarks
    # add 'restrict_with_error' --> if a bookmark exists, deletion fails
    has_many :lists, through: :bookmarks

    validates :title, presence: true, uniqueness: true
    validates :overview, presence: true, uniqueness: true
end
