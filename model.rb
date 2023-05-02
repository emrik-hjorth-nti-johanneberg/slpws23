module Model

    # Connects to the database
    # 
    def dbConnect()
        db = SQLite3::Database.new("db/guides.db")
        db.results_as_hash = true
        return db
    end

    # Selects all items with a relation to the selected guide
    def items(id)
        db = dbConnect()
        items = db.execute("SELECT Items.* FROM Items INNER JOIN Guide, GuideItemRelation ON Items.item_id = GuideItemRelation.item_id AND Guide.id = GuideItemRelation.guide_id WHERE Guide.id = ?",id)
        return items
    end

    # Selects all items in the database
    # 
    # @return [hash]
    def allItems()
        db = dbConnect()
        return db.execute("SELECT * FROM Items")
    end

    # Updates the guides title and champ
    # 
    # @param [string] :id, the selected guides id
    # @param [string] :champ, the selected champs name
    # @param [string] :guide, the guides title
    def updateGuide(id, champ, guideTitle)
        db = dbConnect()
        # id = params[:id]
        # champ = params[:champ]
        # guideTitle = params[:guide]

        db.execute("UPDATE Guide SET champ_id = ?, title = ? WHERE id = ?",champ,guideTitle,id)
    end

    # Updates the guides items
    # 
    # @param [string] :id, the selected guides id
    # @param [string] :guide, the guides title 
    # @param [string] :champ, the selected champs name 
    # @param [hash] :item, all the selected items
    def updateGuideItems(id, champ, guideTitle, items)
        db = dbConnect()
        db.execute("DELETE FROM GuideItemRelation WHERE guide_id = ?",id)
        for i in 0..6 do
            if items[i] != ''
                insertGuideEdit = db.execute("INSERT INTO GuideItemRelation (guide_id,item_id) VALUES (?,?)",id,items[i])
            end
        end
    end

    # Selects all champs in the database
    # 
    # @return [hash] A hash with all of the champs data
    # @option [string] the champs name
    # @option [integer] the champs id

    def allChamps()
        db = dbConnect()
        champs = db.execute("SELECT * FROM Champ")
        return champs
    end

    # Selects and joins all guides and all of their containing data together from the database
    #  
    # @return [array] Array with hashes for all listed guides
    # @option [hash] hash with all information from a guide
    # @option [string] title, the guides title
    # @option [string] name, the selected champs name
    # @option [integer] user_id, the id of the user
    # @option [integer] id, the id of the selected guide
    # @option [integer] champ_id, the id of the selected champ
    def guideList()
        db = dbConnect()
        guides = db.execute("SELECT * FROM Guide INNER JOIN Champ ON Guide.champ_id = Champ.champ_id")
        return guides
    end

    # Selects the logged in users data from the database
    # 
    # @param [string] :password, the password of the user
    # @param [string] :username, the username of the user
    # 
    # @return [hash]
    # @option [string] The username
    # @option [integer] The user's encrypted password
    # @option [integer] The user's id
    def resultUser(username)
        db = dbConnect()
        # password = params[:password]
        # username = params[:username]
        result = db.execute("SELECT * FROM User WHERE name = ?", username).first
        return result
    end

    # Checks if the input password is the same as the encrypted password saved in the database and then logs you in
    # 
    # @param [string] :password, the password of the user
    # @param [string] :username, the username of the user
    # def loginCheck(username, password)
        # # username = params[:username]
        # # password = params[:password]
        # result = resultUser()
        # pwdigest = result["pwdigest"]
        # id = result["id"]
        # if BCrypt::Password.new(pwdigest) == password
        #     session["id"] = id
        #     session["username"] = username
        #     p "Login Successful"
        #     session["isloggedin"] = true
        #     redirect("/")
        # else
        #     "Wrong username or password."
        # end
    # end

    # Selects a certain guide's creator's id
    # 
    # @return [string] the creator's user_id
    def userId(id)
        db = dbConnect()
        # id = params[:id]
        return db.execute("SELECT user_id FROM Guide WHERE id = ?", id).first
    end

    # Gets the param id of the selected guide
    # 
    # @param [integer] :id, the selected guide's id
    # 
    # @return [integer] :id, the selected guide's id
    # def guideId()
    #     return params[:id]
    # end

    # Selects and joins the selected guide and all of its data from the database
    # 
    # @param [integer] :id, the selected guide's id
    # 
    # @return [hash] hash with all information from a guide
    # @option [string] title, the guides title
    # @option [string] name, the selected champs name
    # @option [integer] user_id, the id of the user
    # @option [integer] id, the id of the selected guide
    # @option [integer] champ_id, the id of the selected champ
    def guideContent(id)
        db = dbConnect()
        # id = params[:id].to_i
        return db.execute("SELECT * FROM Guide INNER JOIN Champ ON Guide.champ_id = Champ.champ_id WHERE Guide.id = ?",id).first()
    end

    # Registers a new user, encrypts the password and saves it to the database
    # 
    # @param [string] :username, The registered user's username
    # @param [string] :password, The registered user's password
    # @param [string] :password_confirm, The confirm-version of the user's password
    def createUser(username, password, password_confirm)
        db = dbConnect()
        # username = params[:username]
        # password = params[:password]
        # password_confirm = params[:password_confirm]
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO User (name, pwdigest) VALUES (?, ?)", username, password_digest)
    end

    # Creates a new guide and saves it to the database
    # 
    # @param [string] :guide, the guides title 
    # @param [string] :champ, the selected champs name 
    def insertGuideCreation(guide, champ, user)
        db = dbConnect()
        # guide = params[:guide]
        # champ = params[:champ]
        # user = session["id"]
        db.execute("INSERT INTO Guide (champ_id,title,user_id) VALUES (?,?,?)",champ,guide,user)
    end

    # Selects the newest guide's id
    # 
    # @return [integer] the newest guide's id
    def latestGuideId()
        db = dbConnect()
        id = db.execute("SELECT id FROM Guide ORDER BY id ASC").last()["id"]
        return id
    end

    # Deletes a guide and the relations for the guide
    # 
    # @param [integer] :id, the selected guide's id
    def deleteGuide(id)
        db = dbConnect()
        # id = params[:id].to_i
        db.execute("DELETE FROM Guide WHERE id = ?", id)
        db.execute("DELETE FROM GuideItemRelation WHERE guide_id = ?", id)
    end

    # Deletes a user and all related information to that user
    #
    # @return [Boolean] @validation, checks if the target is an admin or not
    # @return [String] "You can't delete an Admin User"
    def deleteUser(id, userId)
        db = dbConnect()
        # db.execute("")
        if userId != 1
            # deleteGuide(id)
            userGuides = db.execute("SELECT * FROM Guide WHERE user_id = ?", userId)
            p userGuides #["user_id"]
            # userGuides.length.each { |i| p userGuides[i]["user_id"]}
            for i in userGuides do
                deleteGuide(i["id"])
            end
            db.execute("DELETE FROM User where id = ?", userId)
            @validation = true
        else
            "You can't delete an Admin User"
        end

    end

    def login_attempt(user)
        db = dbConnect()
        db.execute("INSERT INTO loginAttempts (user, time) VALUES (?,?)", user, Time.now.to_i)
        result = db.execute("SELECT * FROM loginAttempts WHERE user = ?", user)
        return result
    end
end
