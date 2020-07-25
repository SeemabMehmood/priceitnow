class CreateHandbags < ActiveRecord::Migration[5.0]
  def change
    create_table :handbags do |t|
      t.integer :reference_no
      t.string :image
      t.text :name
      t.text :website
      t.integer :cost
      t.string :condition
      t.string :expert
      t.string :collection
      t.string :color
      t.string :model
      t.string :gender
      t.string :material
      t.integer :length
      t.integer :height
      t.integer :width
      t.string :category

      t.timestamps
    end
  end
end
