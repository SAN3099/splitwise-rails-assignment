class MakeExpenseItemOptional < ActiveRecord::Migration[6.1]
 def change
    change_column_null :expense_participants, :expense_item_id, true
  end
end
