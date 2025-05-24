class TransactionsController < ApplicationController
  before_action :load_ledger

  def create
    if transaction_params[:amount].blank? || transaction_params[:transaction_type].blank?
      render json: { success: false, error: "Missing required parameters." }, status: :unprocessable_entity
      return
    end

    transaction_response = @ledger.create_transaction(
      transaction_params[:amount],
      transaction_params[:transaction_type],
      transaction_params[:timestamp]
    )

    response_status = transaction_response[:success] ? :ok : :unprocessable_entity

    render json: transaction_response, status: response_status
  end

  def balance
    render json: { balance: @ledger.balance }, status: :ok
  end

  def history
    render json: { transactions: @ledger.transaction_history }, status: :ok
  end

  private

  def transaction_params
    params.require(:transaction).permit(:amount, :transaction_type, :timestamp)
  end

  def load_ledger
    @ledger ||= Ledger.instance
  end
end
