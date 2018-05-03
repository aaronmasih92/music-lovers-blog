class UsersTable < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :firstname
      t.string :lastname
      t.string :bday
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
