class Expense < ApplicationRecord
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  has_many :expense_items, dependent: :destroy
  has_many :expense_participants, dependent: :destroy

  validates :description, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }


 
end