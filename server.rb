# frozen_string_literal: true

require 'bundler/setup'
require 'sinatra'
require 'json'
require 'sqlite3'

database = SQLite3::Database.new(File.expand_path(File.dirname(__FILE__), 'messages.sqlite3'))
database.execute('CREATE TABLE IF NOT EXISTS messages (id INTEGER PRIMARY KEY ASC, message TEXT)')

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['hello', 'world']
  end
end

post '/messages' do
  headers 'Content-Type' => 'application/json'
  status 201
  message = JSON.parse(request.body.read)
  database.execute("INSERT INTO messages (message) VALUES (?)", message['message'])
  id = database.last_insert_row_id
  logger.info("You said: #{message['message']}")
  JSON.dump({ id: id, message: message['message'] })
end

get '/messages' do
  headers 'Content-Type' => 'application/json'
  messages = database.execute('SELECT id, message FROM messages ORDER BY id ASC').map do |row|
    { id: row[0], message: row[1] }
  end
  JSON.dump({ messages: messages })
end

delete '/messages/:id' do
  protected!
  database.execute('DELETE FROM messages WHERE id = :id', id: params[:id])
  status 204
end

get '/' do
  headers 'Content-Type' => 'application/json'
  JSON.dump({ greeting: 'Hello World' })
end
