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
      SELECT name, id
      FROM actors
      ORDER BY name ASC
    )
    conn.exec(get_actors_query)
  end
  erb :actors
end

get '/actors/:id' do
  @actor_id = params[:id]
  actor_id_a = []
  actor_id_a << @actor_id.to_i
  @actor_info = db_connection do |conn|
    get_actor_info_query = %(
      SELECT actors.name AS actor_name, movies.id AS movie_id, movies.title AS movie,
        cast_members.character
      FROM movies
        JOIN cast_members ON movies.id = cast_members.movie_id
        JOIN actors ON cast_members.actor_id = actors.id
      WHERE actors.id = $1
      )
      conn.exec_params(get_actor_info_query, actor_id_a)
    end
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
  movie_id_a = []
  movie_id_a << @movie_id.to_i
  db_connection do |conn|
    get_movie_info_query = %(
      SELECT movies.title, movies.year, movies.synopsis, movies.rating,
        genres.name AS genre, studios.name AS studio
      FROM movies
        JOIN genres ON movies.genre_id = genres.id
        RIGHT OUTER JOIN studios ON movies.studio_id = studios.id
      WHERE movies.id = $1
    )
    @movie_info = conn.exec_params(get_movie_info_query, movie_id_a)

    get_cast_info_query = %(
      SELECT cast_members.character AS characters, actors.name AS actors, actors.id
      FROM cast_members
        JOIN actors ON cast_members.actor_id = actors.id
      WHERE cast_members.movie_id = $1
    )
    @cast_info = conn.exec_params(get_cast_info_query, movie_id_a)
  end
  erb :show_movie
end
#
# @actor_info = db_connection do |conn|
#   get_actor_info_query = %(
#     SELECT actors.name AS actor, movies.title, cast_members.character
#     FROM actors
#       JOIN cast_members ON actors.id = cast_members.actor_id
#       JOIN movies ON cast_members.movie_id = movies.id
#     WHERE actors.name LIKE "Tom Hanks"
#   )
#   conn.exec(get_actor_info_query)
# end
