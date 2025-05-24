require "rails_helper"

describe Transaction do
  let(:subject) { described_class.new(type, amount, timestamp) }
  let(:type) { Transaction::TRANSACTION_TYPES[-1] }
  let(:amount) { 50.0 }
  let(:timestamp) { Time.now }
  describe "#valid?" do
    context "when attributes are valid" do
      it "returns true with no errors" do
        expect(subject.valid?).to eq(true)
        expect(subject.errors).to eq([])
      end
    end

    context "when transaction_type is invalid" do
      let(:type) { "ACH" }
      it "returns false and adds transaction_type error to transaction" do
        expect(subject.valid?).to eq(false)
        expect(subject.errors[0]).to match(/is not a valid transaction type, 'transaction_type' must be one of/)
      end
    end

    context "when amount is invalid" do
      let(:amount) { -100 }
      it "returns false and adds amount error to transaction" do
        expect(subject.valid?).to eq(false)
        expect(subject.errors[0]).to eq("Amount must be a non negative numeric value.")
      end
    end

    context "when timestamp is invalid" do
      let(:timestamp) { "tuesday" }
      it "returns false and adds timestamp error to transaction" do
        expect(subject.valid?).to eq(false)
        expect(subject.errors[0]).to match("Timestamp is an invalid time format YYYY-MM-DD HH:MM:SS")
      end
    end
  end

  describe "#effective_amount" do
    context "when deposit" do
      let(:type) { "deposit" }

      it "returns positive amount" do
        expect(subject.effective_amount).to eq(amount)
      end
    end

    context "when withdraw" do
      it "returns negative amount" do
        expect(subject.effective_amount).to eq((-1 * amount))
      end
    end
  end

  describe "#deposit?" do
    context 'when deposit type' do
      let(:type) { "deposit" }
      it "returns true" do
        expect(subject.deposit?).to eq(true)
      end
    end

    context 'when withdraw type' do
      it "returns false" do
        expect(subject.deposit?).to eq(false)
      end
    end
  end
end
