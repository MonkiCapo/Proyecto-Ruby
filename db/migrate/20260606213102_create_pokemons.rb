class CreatePokemons < ActiveRecord::Migration[8.1]
  def change
    create_table :pokemons do |t|
      t.string :name, null: false
      t.string :species, null: false
      t.integer :level, default: 1, null: false
      t.integer :experience, default: 0, null: false
      t.integer :hunger, default: 50, null: false
      t.integer :happiness, default: 50, null: false
      t.datetime :last_interaction

      t.timestamps
    end
  end
end
