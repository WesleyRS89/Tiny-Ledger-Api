require "rails_helper"

describe TransactionsController, type: :request do
  let(:params) { { transaction: { amount: 5.0, transaction_type: "deposit" } } }
  let(:ledger) { instance_double(Ledger) }


  before do
    allow(Ledger).to receive(:instance).and_return(ledger)
  end

  describe "#create" do
    before do
      allow(ledger).to receive(:create_transaction).and_return(transaction_response)
    end
    let(:transaction_response) { { success: true } }
    context "with valid params" do
      it "calls #create_transaction on Ledger with correct params" do
        expect(ledger).to receive(:create_transaction).with("5.0", "deposit", nil).once
        post "/transactions", params: params
      end

      context "when transaction is successful" do
        let(:transaction_response) {
          {
            current_balance: 15.00,
            success: true,
            transaction_amount: 5.0,
            transaction_type: "deposit"
          }
        }
        it "returns transaction info with status ok" do
          post "/transactions", params: params
          expect(response.body).to eq(transaction_response.to_json)
          expect(response.status).to eq(200)
        end
      end

      context "when transaction fails" do
        let(:transaction_response) {
          {
            success: false,
            errors: "something has gone wrong"
          }
        }
        it "returns transaction error with status unprocessible entity" do
          post "/transactions", params: params
          expect(response.body).to eq(transaction_response.to_json)
          expect(response.status).to eq(422)
        end
      end
    end

    context "with invalid params" do
      let(:bad_params) { { transaction: { money: 5.0, account_id: "1234" } } }
      let(:expected_response) { { success: false, error: "Missing required parameters." } }
      it "returns an error" do
        post "/transactions", params: bad_params
        expect(response.body).to eq(expected_response.to_json)
        expect(response.status).to eq(422)
      end
    end
  end

  describe "#balance" do
    let(:balance) { 100.10 }

    before do
      allow(ledger).to receive(:balance).and_return(balance)
    end

    it "returns balance of the ledger" do
      get "/balance"
      expect(response.body).to eq({ balance: balance }.to_json)
      expect(response.status).to eq(200)
    end
  end

  describe "#transaction_history" do
    before do
      allow(ledger).to receive(:transaction_history).and_return(transaction_history)
    end

    let(:transaction_history) {  [
      { transaction_type: "deposit", transaction_amount: "1.00", transaction_date: "2025-05-23 00:00:0000" },
      { transaction_type: "deposit", transaction_amount: "5.50", transaction_date: "2025-05-23 00:00:0000" },
      { transaction_type: "withdraw", transaction_amount: "4.50", transaction_date: "2025-05-23 00:00:0000" }
    ]}

    it "returns the transaction history for the ledger" do
      get "/transaction_history"
      expect(response.body).to eq({ transactions: transaction_history }.to_json)
      expect(response.status).to eq(200)
    end
  end
end
