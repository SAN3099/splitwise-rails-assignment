class ExpenseItem < ApplicationRecord
  belongs_to :expense
  has_many :expense_participants, dependent: :destroy

  validates :name, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  def split_amount(participants_count)
    split_type == 'equal' ? amount / participants_count : 0  # Custom handled in controller/form
  end
end