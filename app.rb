require 'rubygems'
require 'sinatra'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] || 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

get '/about' do
  erb :about
end

get '/contacts' do
  erb :contacts
end

get '/visit' do
  erb :visit
end

post '/visit'  do
  err_validate = {
    user_name: 'Укажите ваше имя',
    user_phone: 'Поле телефон должно быть заполнено',
    visit_time: 'Укажите время визита'
  }
  @user_name = params[:user_name]
  @user_phone = params[:user_phone]
  @visit_time = params[:visit_time]
  @colorpicker = params[:colorpicker]
  @master = params[:master]
  err_validate.each do |key, _val|
    if params[key] == ''
      @error = err_validate[key]
      return erb :visit
    end
  end
  f = File.open('public/visits.txt', 'a')
  f.write("User: #{@user_name}, Phone: #{@user_phone}, Visit time: #{@visit_time},
 Master: #{@master}, Color: #{@colorpicker}\n")
  f.close
  redirect to '/visit'
end

post '/contacts' do
  @user_email = params[:user_email]
  @user_message = params[:user_message]
  contact_valid = {
    user_email: 'Укажите ваш E-mail:',
    user_message: 'Сообщение не может быть пустым'
  }
  contact_valid.each do |key, _val|
    if params[key] == ''
      @error = contact_valid[key]
      return erb :contacts
    end
  end
  f = File.open('public/contacts.txt', 'a')
  f.write("User E-mail: #{@user_email}, Message: #{@user_message}\n")
  f.close
  redirect to '/contacts'
end
