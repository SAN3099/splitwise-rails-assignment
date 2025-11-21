class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def create
    filtered_params = expense_params.deep_dup

    # Remove blank items
    if filtered_params[:items].present?
      filtered_params[:items] = filtered_params[:items].select do |_, item|
        item["name"].present? && item["amount"].to_f > 0
      end
    end

    if filtered_params[:description].blank?
      redirect_to root_path, alert: "Description can't be blank" and return
    end

    ExpenseCreator.new(current_user, filtered_params).call
    redirect_to root_path, notice: "Expense added successfully!"
  rescue => e
    redirect_to root_path, alert: "Error: #{e.message}"
  end

  def destroy
    expense = Expense.find(params[:id])
    expense.destroy
    redirect_to root_path, notice: "Expense removed!"
  end

  private

  def expense_params
    params.require(:expense).permit(
      :description,
      :tax_amount,
      participant_ids: [],
      items: [:name, :amount, :split_type, unequal_splits: {}]
    )
  end
end
