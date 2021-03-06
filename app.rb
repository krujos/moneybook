require 'sinatra'
require 'google/api_client'
require 'google/api_client/auth/installed_app'
require 'google/api_client/client_secrets'


#enable :sessions
use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :expire_after => 31536000, 
                           :secret => ENV['SHEET_KEY']

def api_client; settings.api_client; end

configure do
  client = Google::APIClient.new(:application_name => 'moneybook', :application_version => 1.0, :access_type => 'offline', :auto_refresh => true)
  secrets = Google::APIClient::ClientSecrets.load
  client.authorization = secrets.to_authorization
  client.authorization.scope = %w(https://docs.google.com/feeds/ https://docs.googleusercontent.com/ https://spreadsheets.google.com/feeds/)

  set :api_client, client
end

helpers do 
  def get_sheet
    s = GoogleDrive.login_with_oauth(user_credentials.access_token)
    s.spreadsheet_by_key(ENV['SHEET_KEY']).worksheets[0]
  end
end

DATE = 1
WHERE = 2
COST = 3
SUM = 4
get '/' do 
  ws = get_sheet
  balance = ws[ws.num_rows, SUM]
  balance['$'] = ''
  haml :index, :locals => { :balance => balance.to_f.round(2) }
end

post '/add' do 
  where = params[:where]
  cost = params[:cost]
 
  ws = get_sheet
  row = ws.num_rows + 1
  ws[row, DATE] = Time.new.strftime('%m/%d/%Y')
  ws[row, WHERE] = where
  ws[row, COST] = cost
  ws[row, SUM] = "=D#{row-1}-C#{row}"
  ws.save()
  redirect '/'
end

####### Cred code #######
before do
  # Ensure user has authorized the app
  if session[:expires_at] && Time.now > session[:expires_at] 
    user_credentials.fetch_access_token!
    session[:expires_at] = Time.now + user_credentials.expires_in
  end
  
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

get '/oauth2authorize' do
  # Request authorization
  redirect user_credentials.authorization_uri.to_s, 303
end

get '/oauth2callback' do
  # Exchange token
  user_credentials.code = params[:code] if params[:code]
  user_credentials.fetch_access_token!
  session[:expires_at] = Time.now + user_credentials.expires_in
  redirect to('/')
end
