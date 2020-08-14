class AddSoldToHandbags < ActiveRecord::Migration[6.0]
  def change
    add_column :handbags, :sold, :boolean, default: false
  end
end
