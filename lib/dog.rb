class Dog
    attr_accessor :id, :name, :breed

    def initialize (props = {})
        @id = props[:id]
        @name = props[:name]
        @breed = props[:breed]        
    end

    def self.create_table
        sql = <<-SQL
                CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
                );
                SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
                DROP TABLE
                IF EXISTS dogs
                SQL
        DB[:conn].execute(sql)
    end
    def save
            sql = <<-SQL
                    INSERT INTO dogs
                    (name, breed)
                    VALUES (?, ?)
                    SQL
            DB[:conn].execute(sql, self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
    end

    def self.create (props)
        dog = Dog.new (props)
        dog.save
        dog
    end

    def self.new_from_db (props)
        dog = Dog.new
        dog.id = props[0]
        dog.name = props[1]
        dog.breed = props[2]
        dog
    end

    def self.find_by_id (id)
        dog = Dog.new
        sql = <<-SQL
                SELECT *
                FROM dogs
                WHERE id = ?
                SQL
        row = DB[:conn].execute(sql, id).flatten
        dog.id = row[0]
        dog.name = row[1]
        dog.breed = row[2]
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
                SELECT * 
                FROM dogs 
                WHERE name = ?
                SQL
        row = DB[:conn].execute(sql, name).flatten
        self.new_from_db(row)
    end

    def self.find_or_create_by(props)
# if props doeesn't have an id, we need to create and return it.
# Otherwise we need to find it.
        sql = <<-SQL
           SELECT * 
           FROM dogs
           WHERE name = ?
           AND breed = ?
           SQL
        row = DB[:conn].execute(sql, props[:name], props[:breed]).flatten
        if !row.empty?
            dog = Dog.new
            dog.id = row[0]
            dog.name = row[1]
            dog.breed = row[2]
            dog
        else
            dog = self.create(props)
        end
    end

    def update 
        sql = <<-SQL
                UPDATE dogs
                SET name = ?
                WHERE id = ?
                SQL
        DB[:conn].execute(sql, self.name, self.id)
    end
end