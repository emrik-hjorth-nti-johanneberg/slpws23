require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

enable :sessions

include Model

# Display login Page
#
get('/login') do

    slim(:login)
end

before('/guide/:id/edit') do
    db = dbConnect()
    id = params[:id].to_i
    user_id = userId(id)
    if session["id"] != user_id["user_id"].to_i || session["id"] != 1
        redirect('/')
    end
end



# Logs you in
# 
# @param [string] :username, the input username
# @param [string] :password, the input password
# 
# @see Model#get_article
post("/login") do
    db = dbConnect()
    db.results_as_hash = true
    password = params[:password]
    username = params[:username]
    login_attempts = login_attempt(username)
    if (login_attempts.length > 5 && Time.now.to_i - login_attempts.reverse[5]["time"] < 10)
        redirect('/login')
    end
    
    
    
    result = resultUser(username)
    p result
    
    if result != nil 
        pwdigest = result["pwdigest"]
        id = result["id"]
        if BCrypt::Password.new(pwdigest) == password
        
            session["id"] = id
            session["username"] = username
            p "Login Successful"
            session["isloggedin"] = true
            redirect("/")
        else
            "jhfjhgfjhfhj"
        end
    else
        "Wrong Username or Password. Please try again"
        # sleep
        # redirect('/')
    end
end

# Registers a new user
# 
# @param [string] :username, the input username that gets registered
# @param [string] :password, the input password that gets registered
# @param [string] :password_confirm, the input that confirms the password
# @see Model#get_article
post("/users/new") do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    
    if (password == password_confirm)
      db = dbConnect()
      createUser(username, password, password_confirm)
      redirect('/')
    else
      p password + " " + password_confirm
      "Passwords did not match"
    end
end

# Logs you out
post("/logout") do
    if session["id"] != nil
      session["id"] = nil
      session["username"] = nil
    end
    session["isloggedin"] = false
    redirect("/")
end 
  
# Register page
# 
get('/showregister') do
    slim(:register)
end

# Display Landing Page
# 
# @see Model#get_article
get ('/') do
    @champs = allChamps()
    @guides = guideList()
    # p @guides
    slim(:"guides/index")
end

# Creates a guide
# 
# @param [String] :champ, the name of the selected champ when creating a guide
# @param [String] :guide, the title of the guide
# 
# @see Model#get_article
post ('/guide/') do 
    guide = params[:guide]
    champ = params[:champ]
    user = session["id"]
    if session["id"] != nil   
        insertGuideCreation(guide, champ, user)
        id = latestGuideId()
        redirect("/guide/#{id}/edit")
    else
        "You have to be logged in to use this feature"
    end
end

# Display guide
# 
# @param [Integer] :id, the selected guides id
# 
# @see Model#get_article
get ('/guide/:id') do
    # id = params[:id]
    db = dbConnect()
    id = params[:id].to_i
    @guideContent = guideContent(id)
    @items = items(id)
    @user_id = userId(id)
    p @items
    slim(:"guides/show")
end

# Delete a guide
# 
# @param [Integer] :id, the selected guides id
# 
# @see Model#get_article
post ('/guide/:id/delete') do
    db = dbConnect()
    id = params[:id].to_i
    user_id = userId(id)
    p user_id
    if session["id"] == user_id["user_id"].to_i || session["id"] == 1
        result = deleteGuide(id)
        redirect('/')
    else
        "You do not have permission to use this function"
    end
end

# Deletes a user and all the related guides
# 
# @param [Integer] :id, the selected guides id
post ('/guide/:id/deleteUser') do
    db = dbConnect()
    id = params[:id].to_i
    p id
    user_id = userId(id)
    p user_id[0]
    if session["id"] == 1
        result = deleteUser(id[0], user_id[0])
        if @validation == true
            redirect('/')
        else 
            "You do not have permission to use this function"
        end
    end
    
end

# Display a guides edit-page
# 
# @param [Integer] :the selected guides id
# 
# @see Model#get_article
get ('/guide/:id/edit') do
    db = dbConnect()
    id = params[:id].to_i
    @champs = allChamps()
    @guideContent = guideContent(id)
    @items = allItems()
    # p @items
    slim(:"guides/edit")
end

# Edits a guide
# 
# @param [Integer] :id, the selected guides id
# @param [string] :champ, the selected champs name
# @param [string] :guide, the title of the guide
# 
# @see Model#get_article
post ('/guide/edit') do
    db = dbConnect()
    id = params[:id]
    champ = params[:champ]
    guideTitle = params[:guide]
    items = []
    for i in 1..7 do
        items << params[:"item#{i}"]
    end
    updateGuide(id, champ, guideTitle)

    updateGuideItems(id, champ, guideTitle, items)
    redirect("guide/#{id}") #lsjhfgls
end