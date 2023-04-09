def dbConnect()
    db = SQLite3::Database.new("db/guides.db")
    db.results_as_hash = true
    return db
end

def items(id)
    db = dbConnect()
    items = db.execute("SELECT Items.* FROM Items INNER JOIN Guide, GuideItemRelation ON Items.item_id = GuideItemRelation.item_id AND Guide.id = GuideItemRelation.guide_id WHERE Guide.id = ?",id)
    return items
end

def allChamps()
    db = dbConnect()
    champs = db.execute("SELECT * FROM Champ")
    return champs
end

def guideList()
    db = dbConnect()
    guides = db.execute("SELECT * FROM Guide INNER JOIN Champ ON Guide.champ_id = Champ.champ_id")
    return guides
end

def insertGuideCreation()
    db = dbConnect()
    guide = params[:guide]
    champ = params[:champ]
    user = session["id"]
    db.execute("INSERT INTO Guide (champ_id,title,user_id) VALUES (?,?,?)",champ,guide,user)
end

def latestGuideId()
    db = dbConnect()
    id = db.execute("SELECT id FROM Guide ORDER BY id ASC").last()["id"]
    return id
end