class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.string :player_board, :limit => 100, :null => false
      t.string :cpu_board, :limit => 100, :null => false
      t.string :player_ships, :limit => 9, :null => false
      t.string :cpu_ships, :limit => 9, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
