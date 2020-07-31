class AddBrandToHandbags < ActiveRecord::Migration[6.0]
  def change
    add_column :handbags, :brand, :string
  end
end
