class CreateSolutions < ActiveRecord::Migration
  def self.up
    create_table :solutions do |t|
      # TODO: can probably just make this the primary key...
      t.integer :board_id
      t.text :value
      t.timestamps
    end
  end

  def self.down
    drop_table :solutions
  end
end

