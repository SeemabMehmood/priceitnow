class AddOnlineSinceToHandbags < ActiveRecord::Migration[6.0]
  def change
    add_column :handbags, :online_since, :date
  end
end
