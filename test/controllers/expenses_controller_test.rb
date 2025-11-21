require "test_helper"

class ExpensesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:user_one)
    sign_in @user
  end

  test "should create expense" do
    assert_difference('Expense.count') do
      post expenses_path, params: {
        expense: {
          description: "Lunch",
          tax_amount: 10,
          participant_ids: [@user.id],
          items: {
            "0" => { name: "Pizza", amount: 200, split_type: "equal" }
          }
        }
      }
    end

    assert_redirected_to root_path
  end

  test "should destroy expense" do
    expense = expenses(:one)

    assert_difference('Expense.count', -1) do
      delete expense_path(expense)
    end

    assert_redirected_to root_path
  end
end
