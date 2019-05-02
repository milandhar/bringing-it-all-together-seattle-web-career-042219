require 'pry'
class Dog
  attr_accessor :name, :id, :breed

  def initialize(dog_hash, id=nil)
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
    @id = id
    #binding.pry
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs
    (ID INTEGER PRIMARY KEY, NAME TEXT, BREED TEXT)
    SQL


    DB[:conn].execute(sql)

  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)

  end

  def save
    sql = <<-SQL
      INSERT INTO dogs
      VALUES(?, ?,?)
    SQL

    DB[:conn].execute(sql, self.id, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    #binding.pry

    Dog.new({name: self.name, breed: self.breed}, @id)



  end

  def self.create(name:, breed:)

    #binding.pry
    new_dog = Dog.new(name: name, breed: breed)

    new_dog.save

  end

  def self.find_by_id(x)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    dog_array = DB[:conn].execute(sql, x)
    #binding.pry
    new_dog = Dog.new(name: dog_array[0][1], breed: dog_array[0][2], id: dog_array[0][0])
    new_dog.id = dog_array[0][0]
    new_dog
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

    if !dog.empty?
      dog_data = dog[0]
      #binding.pry
      dog = Dog.new(name: dog_data[1], breed: dog_data[2])
      dog.id = dog_data[0]
    else
      #binding.pry

      dog = self.create(name: name, breed: breed)
    end
    dog

  end

  def self.new_from_db(row)

      dog = Dog.new(name: row[1], breed: row[2])
      dog.id = row[0]
      dog
  end

  def self.find_by_name(name)

    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)

    new_dog = self.create(name: row[0][1], breed: row[0][2])
    new_dog.id = row[0][0]
    new_dog

  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
