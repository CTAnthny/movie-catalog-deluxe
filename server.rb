require "sinatra"
require "pg"

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
