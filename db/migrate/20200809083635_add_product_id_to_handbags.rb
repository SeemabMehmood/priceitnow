class AddProductIdToHandbags < ActiveRecord::Migration[6.0]
  def change
    add_column :handbags, :product_id, :string
  end
end
