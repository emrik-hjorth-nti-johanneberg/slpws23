require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

enable :sessions

get ('/login') do

    slim(:"login")
end

post("/login") do
    username = params[:username]
    password = params[:password]
  
    db = dbConnect()
    db.results_as_hash = true
    result = db.execute("SELECT * FROM User WHERE name = ?", username).first
    
    if result == nil 
      "Wrong username or password."
      return
    end

    pwdigest = result["pwdigest"]
    id = result["id"]

    if BCrypt::Password.new(pwdigest) == password
        session["id"] = id
        session["username"] = username
        p "Login Successful"
        session["isloggedin"] = true
        redirect("/")
    else
        "Wrong username or password."
    end
    
end

post("/users/new") do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    
    if (password == password_confirm)
      password_digest = BCrypt::Password.create(password)
      db = dbConnect()
      db.execute("INSERT INTO User (name, pwdigest) VALUES (?, ?)", username, password_digest)
      redirect('/')
    else
      p password + " " + password_confirm
      "Passwords did not match"
    end
end

post("/logout") do
    if session["id"] != nil
      session["id"] = nil
      session["username"] = nil
    end
    session["isloggedin"] = false
    redirect("/")
end 
  

get('/showregister') do
    slim(:register)
end

get ('/') do
    @champs = allChamps()
    @guides = guideList()
    p @guides
    slim(:"guides/index")
end

post ('/guide/') do 
    insertGuideCreation()
    id = latestGuideId()
    redirect("/guide/#{id}/edit")
end

get ('/guide/:id') do
    db = dbConnect()
    id = params[:id].to_i
    @guideContent = db.execute("SELECT * FROM Guide INNER JOIN Champ ON Guide.champ_id = Champ.champ_id WHERE Guide.id = ?",id).first()
    @items = items(id)
    p @items
    slim(:"guides/show")
end

post ('/guide/:id/delete') do
    db = dbConnect()
    id = params[:id].to_i
    user_id = db.execute("SELECT user_id FROM Guide WHERE id = ?", id)
    p user_id
    if session["id"] = user_id
        result = db.execute("DELETE FROM Guide WHERE id = ?", id)
        redirect('/')
    else
        "You do not have permission to use this function"
    end
end

get ('/guide/:id/edit') do
    db = dbConnect()
    id = params[:id].to_i
    @champs = db.execute("SELECT * FROM Champ")
    @guideContent = db.execute("SELECT * FROM Guide INNER JOIN Champ ON Guide.champ_id = Champ.champ_id WHERE Guide.id = ?",id).first()
    # @items = db.execute("SELECT Items.* FROM Items INNER JOIN Guide, GuideItemRelation ON Items.item_id = GuideItemRelation.item_id AND Guide.id = GuideItemRelation.guide_id WHERE Guide.id = ?",id)
    @items = db.execute("SELECT * FROM Items")
    # p @items
    slim(:"guides/edit")
end

post ('/guide/edit') do
    db = dbConnect()
    id = params[:id]
    champ = params[:champ]
    guideTitle = params[:guide]

    db.execute("UPDATE Guide SET champ_id = ?, title = ? WHERE id = ?",champ,guideTitle,id)

    items = []
    for i in 1..7 do
        items << params[:"item#{i}"]
    end
    p items[0]
    # @guideContent = db.execute("")
    db.execute("DELETE FROM GuideItemRelation WHERE guide_id = ?",id)
    for i in 0..6 do
        if items[i] != ''
            insertGuideEdit = db.execute("INSERT INTO GuideItemRelation (guide_id,item_id) VALUES (?,?)",id,items[i])
        end
    end
    redirect("guide/#{id}")
end