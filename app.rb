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
    id = db.execute("SELECT id FROM Guide ORDER BY id ASC").last()["id"]
    redirect("/guide/#{id}/edit")
end

get ('/guide/:id') do
    db = dbConnect()
    id = params[:id].to_i
    @guideContent = db.execute("SELECT * FROM Guide INNER JOIN Champ ON Guide.champ_id = Champ.champ_id WHERE Guide.id = ?",id).first()
    @items = db.execute("SELECT Items.* FROM Items INNER JOIN Guide, GuideItemRelation ON Items.item_id = GuideItemRelation.item_id AND Guide.id = GuideItemRelation.guide_id WHERE Guide.id = ?",id)
    p @items
    slim(:"guides/show")
end

post ('/guide/:id/delete') do
    db = dbConnect()
    id = params[:id].to_i
    result = db.execute("DELETE FROM Guide WHERE id = ?", id)
    redirect('/')
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
    id = params[:id]
    # items = params[:]


    redirect("guide/#{id}")
end