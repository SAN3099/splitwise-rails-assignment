class CreateExpenseParticipants < ActiveRecord::Migration[6.1]
  def change
    create_table :expense_participants do |t|
      t.references :user, null: false, foreign_key: true
      t.references :expense, null: false, foreign_key: true
      t.references :expense_item, null: false, foreign_key: true
      t.integer :amount_owed, default: 0

      t.timestamps
    end
  end
end
