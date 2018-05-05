class AddColumnsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :fav_artist, :string
    add_column :users, :instrument, :string
  end
end
