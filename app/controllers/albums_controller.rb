require_relative '../../config/key.rb'

class AlbumsController < ApplicationController
    def index
        @albums = Album.all 

        render json: @albums
    end

    def show 
        @album = Album.find(params[:id])

        render json: @album
    end

    def create    

        spot_id = get_spotify_id(params[:name])
    
        rest_client = RestClient.get("https://api.spotify.com/v1/albums/#{spot_id}",
        'Authorization' => "Bearer #{get_token}")
        response = JSON.parse(rest_client)  
    
        album_exists = Album.all.any? {|album| album["name"] == response["name"]} 
        
        if album_exists == true
            puts "Album already exists"
        else
            @album = Album.create({
            name: response["name"], 
            musicians: response["artists"].map{|artist| artist["name"]},
            songs: response["tracks"]["items"].map{|track| track["name"]},
            spotify_id: response["id"],
            image: response["images"][0]["url"]
            })
        end
        
        redirect_to "http://localhost:3001"
    end
    
    def get_spotify_id(album_name)
        
        rest_client = RestClient.get("https://api.spotify.com/v1/search?q=#{album_name}&type=album",
        'Authorization' => "Bearer #{get_token}")
        response = JSON.parse(rest_client)  
    
        album_id = response["albums"]["items"].map do |item|
            item["id"]
        end.first
        album_id
    end
    
    
    def get_token
        base_url = "https://api.spotify.com/v1"
        # attr_accessor :access_token
        # def self.access_token
        token = RestClient.post('https://accounts.spotify.com/api/token',
            {'grant_type': 'client_credentials'},
            {'Authorization': "Basic #{SpotifyKey::KEY}"})
        JSON.parse(token)['access_token']
        # end
    end
end
   