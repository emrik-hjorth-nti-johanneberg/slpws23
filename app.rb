require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'


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
    db = dbConnect()
    id = params[:id]

    items = []
    for i in 1..7 do
        items << params[:"item#{i}"]
    end
    p items[0]
    for i in 0..6 do
        insertGuideEdit = db.execute("INSERT INTO GuideItemRelation (guide_id,item_id) VALUES (?,?)",id,items[i])
    end
    redirect("guide/#{id}")
end