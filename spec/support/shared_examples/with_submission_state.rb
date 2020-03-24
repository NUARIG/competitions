RSpec.shared_examples 'WithSubmissionState' do
  let(:instance) { described_class.new }

  it 'should respond to #submitted?' do
    expect(instance).to respond_to(:submitted?)
  end
end
