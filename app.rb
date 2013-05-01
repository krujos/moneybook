require 'sinatra'
require 'dotenv'
require 'google/api_client'
Dotenv.load

enable :sessions

def api_client; settings.api_client; end

get '/' do 
  haml :index
end

post '/add' do 
  where = params[:where]
  cost = params[:cost]
  s = GoogleDrive.login_with_oauth(user_credentials.access_token)
  ws = session[:drive].spreadsheet_by_key(ENV['SHEET_KEY']).worksheets[0]
  
  row = ws.num_rows + 1
  ws[row, 1] = where
  ws[row, 2] = cost
 # ws[row, 3] = '=' + ws[ws.num_rows,3] + '-' + ws[row, 2]
  ws.save()
  redirect "/"
end

before do
  # Ensure user has authorized the app
  unless user_credentials.access_token || request.path_info =~ /^\/oauth2/
    redirect to('/oauth2authorize')
  end
end

after do
  # Serialize the access/refresh token to the session
  session[:access_token] = user_credentials.access_token
  session[:refresh_token] = user_credentials.refresh_token
  session[:expires_in] = user_credentials.expires_in
  session[:issued_at] = user_credentials.issued_at
end

def user_credentials
  # Build a per-request oauth credential based on token stored in session
  # which allows us to use a shared API client.
  @authorization ||= (
    auth = api_client.authorization.dup
    auth.redirect_uri = to('/oauth2callback')
    auth.update_token!(session)
    auth
  )
end

configure do
  client = Google::APIClient.new(:application_name => "moneybook", :application_version => 0.01)
  client.authorization.client_id = ENV['CLIENT_ID']
  client.authorization.client_secret = ENV['CLIENT_SECRET']
  client.authorization.scope = 'https://docs.google.com/feeds/ ' + "https://docs.googleusercontent.com/ "  + "https://spreadsheets.google.com/feeds/"

  set :api_client, client
end

get '/oauth2authorize' do
  # Request authorization
  redirect user_credentials.authorization_uri.to_s, 303
end

get '/oauth2callback' do
  # Exchange token
  user_credentials.code = params[:code] if params[:code]
  user_credentials.fetch_access_token!
  redirect to('/')
end
