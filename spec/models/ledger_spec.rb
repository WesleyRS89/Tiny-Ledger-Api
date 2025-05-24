require 'rails_helper'

describe Ledger do
  subject(:ledger) { described_class.instance }
  let(:curr_time) { "2025-05-23 10:11:17 -0700" }

  before do
      # stub time
      allow(Time).to receive(:now).and_return(Time.new(curr_time))

      # Since Ledger is singleton need to reset attributes between test cases
      subject.instance_variable_set(:@transactions, [])
      subject.instance_variable_set(:@balance, 0)
  end

  describe "#create_transaction" do
    context "when successful deposit" do
      let(:deposit_amount) { 5 }

      it "returns transaction details" do
        response = subject.create_transaction(deposit_amount, "deposit", curr_time)
        expect(response).to eq({
          current_balance: ('%.2f' %  deposit_amount),
          success: true,
          transaction_amount: ('%.2f' %  deposit_amount),
          transaction_type: "deposit"
        })
      end

      it "adds transaction to transactions attribute" do
        subject.create_transaction(deposit_amount, "deposit", curr_time)
        expect(subject.transactions.count).to eq(1)
        expect(subject.transactions[0].transaction_type).to eq("deposit")
        expect(subject.transactions[0].amount).to eq(deposit_amount)
        expect(subject.transactions[0].timestamp).to eq(curr_time)
      end

      it "updates balance" do
        subject.create_transaction(deposit_amount, "deposit", curr_time)
        expect(subject.balance).to eq(deposit_amount)
      end
    end

    context "when successful withdraw" do
      let(:withdraw_amount) { 5 }
      let(:current_balance) { 15 }
      let(:remaining_balance) { current_balance - withdraw_amount }

      before do
        subject.instance_variable_set(:@balance, current_balance)
      end

      it "returns transaction details" do
        response = subject.create_transaction(withdraw_amount, "withdraw", curr_time)

        expect(response).to eq({
          current_balance: ('%.2f' % remaining_balance),
          success: true,
          transaction_amount: ('%.2f' %  withdraw_amount),
          transaction_type: "withdraw"
        })
      end

      it "adds transaction to transactions attribute" do
        subject.create_transaction(withdraw_amount, "withdraw", curr_time)
        expect(subject.transactions.count).to eq(1)
        expect(subject.transactions[0].transaction_type).to eq("withdraw")
        expect(subject.transactions[0].amount).to eq(withdraw_amount)
        expect(subject.transactions[0].timestamp).to eq(curr_time)
      end

      it "updates balance" do
        subject.create_transaction(withdraw_amount, "withdraw", curr_time)
        expect(subject.balance).to eq(remaining_balance)
      end
    end

    context "when failed transaction" do
      it "returns error details" do
        response = subject.create_transaction(-2, "withdraw", curr_time) # negative amount will cause validation error
        expect(response).to eq({
          errors: "Amount must be a non negative numeric value.",
          success: false
        })
      end

      it "does not store failed transaction in transactions" do
        subject.create_transaction(-2, "withdraw", curr_time)
        expect(subject.transactions).to eq([])
      end

      it "does not update balance" do
        subject.create_transaction(-2, "withdraw", curr_time)
        expect(subject.balance).to eq(0)
      end
    end
  end

  describe "#formatted_balance" do
    before do
      # make deposits to return a balance
      subject.instance_variable_set(:@balance, 6)
    end

    it "returns the formatted value of balance attribute" do
      expect(subject.formatted_balance).to eq("6.00")
    end
  end

  describe "#transaction_history" do
    context "with transactions" do
      before do
        # add transacations to return
        subject.create_transaction(1, "deposit", curr_time)
        subject.create_transaction(5.5, "deposit", curr_time)
        subject.create_transaction(4.5, "withdraw", curr_time)
      end
      let(:expected_transactions) {
        [
          { transaction_type: "deposit", transaction_amount: "1.00", transaction_date: curr_time },
          { transaction_type: "deposit", transaction_amount: "5.50", transaction_date: curr_time },
          { transaction_type: "withdraw", transaction_amount: "4.50", transaction_date: curr_time }
        ]
      }

      it "returns an array of transactions" do
        expect(subject.transaction_history).to eq(expected_transactions)
      end
    end

    context "without transactions" do
      it "returns an empty array" do
        expect(subject.transaction_history).to eq([])
      end
    end
  end
end
