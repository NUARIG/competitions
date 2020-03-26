RSpec.shared_examples 'WithScoring' do
  let(:instance) { described_class.new }

  context '#calculate_average_score' do
    it 'returns a calculated average of an array' do
      scores = [3,3,4]
      expect(instance.calculate_average_score(scores)).to eql 3.33
    end

    it 'does not include nil in denominator count when calculating average of an array' do
      scores = [nil, 3,3,4]
      expect(instance.calculate_average_score(scores)).to eql 3.33
    end

    it 'returns zero when it receives an empty array' do
      empty_scores = []
      expect(instance.calculate_average_score(empty_scores)).to eql 0
    end

    it 'returns zero when it receives an array of nils' do
      empty_scores = [nil, nil, nil]
      expect(instance.calculate_average_score(empty_scores)).to eql 0
    end
  end
end
