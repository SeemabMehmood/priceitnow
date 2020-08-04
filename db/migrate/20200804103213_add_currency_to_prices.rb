class AddCurrencyToPrices < ActiveRecord::Migration[6.0]
  def change
    add_column :prices, :currency, :string
  end
end
