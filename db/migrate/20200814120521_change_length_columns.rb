class ChangeLengthColumns < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      change_table :handbags do |t|
        dir.up   { t.change :length, :decimal ; t.change :height, :decimal ; t.change :width, :decimal }
        dir.down { t.change :length, :integer ; t.change :height, :integer ; t.change :width, :integer }
      end

      change_table :prices do |t|
        dir.up   { t.change :price, :decimal, precision: 10, scale: 2, default: 0.0, using: 'price::numeric' }
        dir.down { t.change :price, :string }
      end
    end
  end
end
