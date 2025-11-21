class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :expenses, foreign_key: :created_by_id
  has_many :expense_participants
  has_many :payments_sent, class_name: 'Payment', foreign_key: :from_user_id
  has_many :payments_received, class_name: 'Payment', foreign_key: :to_user_id

  # ---- TOTAL BALANCES ----
  def total_owed
    ExpenseParticipant
      .where(user_id: id)
      .where("amount_owed > 0")
      .joins(:expense)
      .where.not(expenses: { created_by_id: id })
      .sum(:amount_owed)
      .to_f.round(2)
  end

  def total_due
    ExpenseParticipant
      .where.not(user_id: id)
      .where("amount_owed > 0")
      .joins(:expense)
      .where(expenses: { created_by_id: id })
      .sum(:amount_owed)
      .to_f.round(2)
  end

  def total_balance
    (total_due - total_owed).to_f.round(2)
  end

  # ---- BALANCE WITH FRIEND ----
  def balance_with(friend)
    owed_by_friend = ExpenseParticipant
                       .where(user_id: friend.id)
                       .where("amount_owed > 0")
                       .joins(:expense)
                       .where(expenses: { created_by_id: id })
                       .sum(:amount_owed)
                       .to_f

    i_owe_friend = ExpenseParticipant
                     .where(user_id: id)
                     .where("amount_owed > 0")
                     .joins(:expense)
                     .where(expenses: { created_by_id: friend.id })
                     .sum(:amount_owed)
                     .to_f

    (owed_by_friend - i_owe_friend).round(2)
  end
end
