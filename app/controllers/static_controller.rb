class StaticController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    @users = User.where.not(id: current_user.id).to_a

    @total_balance = current_user.total_balance
    @you_owe      = current_user.total_owed
    @you_are_owed = current_user.total_due

    # build an array of [user, balance] where balance = current_user.balance_with(user)
    user_balances = @users.map { |u| [u, current_user.balance_with(u)] }

    # users current_user owes (negative balances) - show absolute amounts
    @owe_list = user_balances.select { |_u, bal| bal < 0 }.map { |u, bal| { user: u, amount: bal.abs } }

    # users who owe current_user (positive balances)
    @owed_list = user_balances.select { |_u, bal| bal > 0 }.map { |u, bal| { user: u, amount: bal } }
    # ONLY friends the current_user owes money to for the settle form
    @owed_friends = @users.select { |u| current_user.balance_with(u) > 0 }
  end

  def person
    @friend = User.find(params[:id])
    @balance = current_user.balance_with(@friend)

    # sidebar list
    @users = User.where.not(id: current_user.id)

    # all expenses that either were created by the friend or include the friend in participants
    @expenses = Expense.includes(:created_by, :expense_items)
                       .joins(:expense_participants)
                       .where('expenses.created_by_id = ? OR expense_participants.user_id = ?', @friend.id, @friend.id)
                       .distinct
  end
end
