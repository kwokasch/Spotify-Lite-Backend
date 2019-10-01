class Album < ApplicationRecord
    has_many :playlists
    has_many :artists, through: :playlists
end
