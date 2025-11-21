class ChangeColumnType < ActiveRecord::Migration[6.1]
  def change
    change_column :expense_participants, :amount_owed, :decimal, precision: 10, scale: 2

  end
end
