# frozen_string_literal: true

require 'net/http'
require 'json'

class Client
  # Initialize a new client. Username and password are option, without
  # however the remove_message method will result in an exception.
  def initialize(hostname, port, username: nil, password: nil)
    @hostname = hostname
    @port     = port
    @username = username
    @password = password
  end

  # Check if the service is available by verifying the result of on /
  def service_available?
    response = get_data('/')
    response['greeting'] == 'Hello World'
  end

  # Get all messages in the service
  def messages
    get_data('/messages')
  end

  # Add a new message
  def add_message(message)
    post_data('/messages', { message: message })
  end

  # Remove the message with the given id (determined through messages or
  # from add_message)
  def remove_message(id)
    delete("/messages/#{id}")
  end

  private

  # Set up the Net::HTTP instance to use throughout this client to send
  # requests.
  def user_agent
    @user_agent ||= Net::HTTP.new(@hostname, @port)
  end

  # Send a HTTP GET request to the given path. If the server does not return
  # HTTP code 200 (ok) an exception is raised. Deserializes the JSON body from
  # the response into a Ruby object and returns that.
  def get_data(path)
    response = user_agent.request(Net::HTTP::Get.new(path))
    raise "GET request failed, server returned status #{response.code}" unless response.code == '200'
    data = JSON.parse(response.body)
  end

  # Send a HTTP POST request to the given path with the data serialized into
  # JSON. If the server does not return HTTP code 201 (created) an exception
  # is raised. Deserializes the JSON body from the response into a Ruby object
  # and returns it.
  def post_data(path, data)
    post = Net::HTTP::Post.new('/messages', 'Content-Type' => 'application/json')
    post.body = JSON.dump(data)
    response = user_agent.request(post)
    raise "POST request failed, server returned status #{response.code}" unless response.code == '201'
    data = JSON.parse(response.body)
  end

  # Send a HTTP DELETE request to the given path. If the server does not return
  # HTTP code 204 (no content) an exception is raised.
  #
  # NOTE: this method is tailored to the service that this client is built for,
  # other REST services might return data with a DELETE with a different HTTP
  # status code.
  def delete(path)
    delete = Net::HTTP::Delete.new(path)
    delete.basic_auth(@username, @password) if @username && @password
    response = user_agent.request(delete)
    raise "DELETE request failed, server returned status #{response.code}" unless response.code == '204'
  end
end
