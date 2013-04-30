require 'sinatra'

get '/' do 
  haml :index
end

post '/add' do 
  where = params[:where]
  cost = params[:cost]
end