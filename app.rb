require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'


get ('/') do
    db = dbConnect()
    @champs = db.execute("SELECT * FROM Champ")
    @guides = db.execute("SELECT * FROM Guide INNER JOIN Champ ON Guide.champ_id = Champ.champ_id")
    p @guides
    slim(:"guides/index")
end

post ('/guide/') do 
    db = dbConnect()
    guide = params[:guide]
    champ = params[:champ]
    db.execute("INSERT INTO Guide (champ_id,title) VALUES (?,?)",champ,guide)
    redirect("/")
end

get ('/guide/:id') do
    db = dbConnect()
    id = params[:id].to_i
    @guideContent = db.execute("SELECT * FROM Guide INNER JOIN Champ ON Guide.champ_id = Champ.champ_id WHERE Guide.id = ?",id).first()
    # @items = db.execute("")
    slim(:"guides/show")
end

post ('/guide/:id/delete') do
    db = dbConnect()
    id = params[:id].to_i
    result = db.execute("DELETE FROM Guide WHERE id = ?", id)
    redirect('/')
end