# REST example

This repository has an example REST service and an example REST client that go with an article that you can read here: https://without-brains.net/

# Running the server

The server (in server.rb) requires the gems in the Gemfile ([https://github.com/sinatra/sinatra](sinatra) and [https://github.com/sparklemotion/sqlite3-ruby](sqlite3)), it uses Bundler to work with them. Run "bundle install" to install them.

Note that sqlite3 comes with a native Ruby extension, you may have to install additional dependencies on your system to make this work.

After installing the gems you can run the server with "ruby server.rb".

# Using the client

The client (in client.rb) does not require any gems, it only uses dependencies found in the Ruby standard library. client.rb only contains the Client class, to use it you need to write your own code that requires it or through IRB (or another REPL).

