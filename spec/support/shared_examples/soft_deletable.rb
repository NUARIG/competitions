RSpec.shared_examples 'soft deletable' do
  RSpec.shared_examples 'updating deleted columns' do
    it 'does not destroy record' do
      expect{ instance.send(delete_method).not_to change{ instance.class.unscoped.count }}
    end

    it 'hides record so it\'s not returned by not_deleted scope' do
      expect{instance.send(delete_method)}.to change{ instance.class.not_deleted.count }.by(-1)
    end

    it 'updates deleted_at column' do
      expect(instance.deleted_at).to be_blank
      instance.send(delete_method)
      expect(instance.deleted_at).not_to be_blank
    end
  end

  describe 'process_soft_delete' do
    let(:delete_method) { :process_soft_delete }
    it_behaves_like 'updating deleted columns'
  end

  describe 'soft_delete!' do
    let(:delete_method) { :soft_delete! }
    it_behaves_like 'updating deleted columns'

    it 'does not soft delete if object is not soft deletable' do
      allow_any_instance_of(instance.class).to receive(:is_soft_deletable?).and_return(false)
      expect(instance.deleted_at).to be_blank
      instance.soft_delete!
      expect(instance.deleted_at).to be_blank
    end
  end

  describe 'is_deleted?' do
    it 'returns true for deleted record' do
      instance.soft_delete!
      expect(instance.deleted?).to be_truthy
    end

    it 'returns false for not deleted record' do
      expect(instance.reload.deleted?).to be_falsy
    end
  end
end
