require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    columns = []
    sql = "PRAGMA table_info (#{table_name})"
    table_info = DB[:conn].execute(sql)
    table_info.each do |column|
      columns << column["name"]
    end
    columns
  end

  def initialize(options = {})
    options.each do |k, v|
      self.send("#{k}=", v)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []

    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name_to_find)
    sql = "SELECT * FROM #{self.table_name} WHERE name = #{name_to_find}"


    self.new(DB[:conn].execute(sql))
  end
end
