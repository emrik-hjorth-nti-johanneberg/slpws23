def dbConnect()
    db = SQLite3::Database.new("db/guides.db")
    db.results_as_hash = true
    return db
end

