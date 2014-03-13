require 'sinatra'

get '/' do
  send_file 'mocks/interface.html'
end