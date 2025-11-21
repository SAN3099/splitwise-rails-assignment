class PaymentSettlement
  def initialize(from_user:, to_user:, amount:, note: nil)
    @from_user = from_user
    @to_user = to_user
    @amount = amount.to_f
    @note = note
  end

  def call
    ActiveRecord::Base.transaction do
      remaining_amount = @amount

      # Fetch all expense participants where from_user owes to to_user
      expense_participants_to_settle.each do |ep|
        break if remaining_amount <= 0

        pay_amount = [ep.amount_owed, remaining_amount].min
        ep.update!(amount_owed: ep.amount_owed - pay_amount)
        remaining_amount -= pay_amount
      end

      if remaining_amount.positive?
        raise "Payment exceeds total owed! Remaining amount: #{remaining_amount.round(2)}"
      end

      Payment.create!(from_user: @from_user, to_user: @to_user, amount: @amount, note: @note)
    end
  end

  private

  def expense_participants_to_settle
    ExpenseParticipant
      .joins(:expense)
      .where(user_id: @from_user.id)
      .where("expenses.created_by_id = ? OR expenses.created_by_id = ?", @to_user.id, @from_user.id)
      .where("amount_owed > 0")
      .order(:created_at)
  end
end
