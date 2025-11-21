class PaymentsController < ApplicationController
  before_action :authenticate_user!  # if you have Devise or similar

  def create
    to_user = User.find(params[:to_user_id])
    amount = params[:amount].to_f
    note = params[:note]

    PaymentSettlement.new(from_user: current_user, to_user: to_user, amount: amount, note: note).call

    redirect_to root_path, notice: "Payment of #{amount} to #{to_user.name} successful!"
  rescue StandardError => e
    redirect_to root_path, alert: e.message
  end
end
