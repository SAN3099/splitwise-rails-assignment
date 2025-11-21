class ExpenseCreator
  def initialize(user, params)
    @user = user
    @expense_params = params[:expense] || params
  end

  def call
    ActiveRecord::Base.transaction do
      participants = Array(@expense_params[:participant_ids]).map(&:to_i)
      tax_amount = (@expense_params[:tax_amount].to_f rescue 0)

      expense = Expense.create!(
        description: @expense_params[:description].to_s.strip,
        tax_amount: tax_amount,
        created_by: @user,
        total_amount: 0
      )

      total_items = create_items(expense, participants)

      # Apply tax equally
      apply_tax_split(expense, participants, tax_amount)

      expense.update!(total_amount: (total_items + tax_amount).round(2))

      expense
    end
  end

  private

  def create_items(expense, participants)
    total = 0

    (@expense_params[:items] || {}).each do |_, item_params|
      name = item_params["name"].to_s.strip
      amount = item_params["amount"].to_f
      split_type = item_params["split_type"] || "equal"
      next if name.blank? || amount <= 0

      item = expense.expense_items.create!(
        name: name,
        amount: amount,
        split_type: split_type
      )
      total += amount

      if split_type == "equal"
        split_amount = participants.any? ? (amount / participants.size).round(2) : 0
        participants.each do |uid|
          expense.expense_participants.create!(
            user_id: uid,
            expense_item_id: item.id,
            amount_owed: split_amount
          )
        end
      elsif split_type == "unequal"
        # Unequal splits provided as hash {user_id => amount}
        item_params["unequal_splits"]&.each do |uid, amt|
          next if amt.to_f <= 0
          expense.expense_participants.create!(
            user_id: uid.to_i,
            expense_item_id: item.id,
            amount_owed: amt.to_f.round(2)
          )
        end
      end
    end

    total.round(2)
  end

  def apply_tax_split(expense, participants, tax_amount)
    return if participants.empty? || tax_amount.to_f <= 0

    tax_share = (tax_amount.to_f / participants.size).round(2)

    participants.uniq.each do |uid|
      expense.expense_participants.create!(
        user_id: uid,
        expense_item_id: nil,
        amount_owed: tax_share
      )
    end
  end
end
