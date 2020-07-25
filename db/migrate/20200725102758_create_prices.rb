class CreatePrices < ActiveRecord::Migration[6.0]
  def change
    create_table :prices do |t|
      t.references :handbag, null: false, foreign_key: true
      t.string :price

      t.timestamps
    end
  end
end
