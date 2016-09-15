require "sinatra"
require "pg"
require 'pry'

set :views, File.join(File.dirname(__FILE__), "app/views")

configure :development do
  set :db_config, { dbname: "movies" }
end

configure :test do
  set :db_config, { dbname: "movies_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get '/actors' do
  @actors = db_connection do |conn|
    get_actors_query = %(
      SELECT name
      FROM actors
      ORDER BY name ASC
    )
    conn.exec(get_actors_query)
  end
  erb :actors
end

get '/actors/:actor_name' do
  @actor_name = params[:actor_name]
  erb :show_actor
end

get '/movies' do
  @movies = db_connection do |conn|
    get_movies_query = %(
      SELECT movies.id, movies.title AS movie, movies.year, movies.rating,
        genres.name AS genre, studios.name AS studio
      FROM movies
        JOIN genres ON movies.genre_id = genres.id
        RIGHT OUTER JOIN studios ON movies.studio_id = studios.id
      ORDER BY movies.title ASC
    )
    conn.exec(get_movies_query)
  end
  erb :movies
end

get '/movies/:id' do
  @movie_id = params[:id]
  erb :show_movie
end
