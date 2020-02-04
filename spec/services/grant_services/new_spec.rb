require 'rails_helper'

RSpec.describe 'GrantServices' do
  describe 'New' do
    let(:new_grant)     { build(:grant) }
    let(:grant_creator) { create(:grant_creator_user)}

    context 'success' do
      it 'creates a grant and its associations' do
        expect do
          GrantServices::New.call(grant: new_grant, user: grant_creator)
        end.to (change{Grant.count}.by 1)
      end

      it 'returns a struct with .success? true' do
        result = GrantServices::New.call(grant: new_grant, user: grant_creator)
        expect(result.success?).to be true
      end

      it 'creates a new permission' do
        expect do
          GrantServices::New.call(grant: new_grant, user: grant_creator)
        end.to (change{GrantPermission.count}.by 1)
      end

      it 'creates a new form and section' do
        expect do
          GrantServices::New.call(grant: new_grant, user: grant_creator)
        end.to (change{GrantSubmission::Form.count}.by 1)
            .and (change{GrantSubmission::Section.count}.by 1)
      end

      it 'creates two default questions' do
        expect do
          GrantServices::New.call(grant: new_grant, user: grant_creator)
        end.to (change{GrantSubmission::Question.count}.by 2)
      end

      it 'creates default review criteria' do
        expect do
          GrantServices::New.call(grant: new_grant, user: grant_creator)
        end.to (change{Criterion.count}.by Criterion::DEFAULT_CRITERIA.count)
      end
    end

    context 'failures' do
      it 'returns a struct with .success? false' do
        allow(GrantPermission).to receive(:create!).and_raise(StandardError)
        result = GrantServices::New.call(grant: new_grant, user: grant_creator)
        expect(result.success?).to be false
      end

      context 'permission' do
        it 'does not create a grant if permission save fails' do
          allow(GrantPermission).to receive(:create!).and_raise(StandardError)
          expect do
            GrantServices::New.call(grant: new_grant, user: grant_creator)
          end.not_to (change{Grant.count})
          expect(GrantPermission.count).to be 0
          expect(GrantSubmission::Form.count).to be 0
          expect(GrantSubmission::Section.count).to be 0
          expect(GrantSubmission::Question.count).to be 0
          expect(Criterion.count).to be 0
        end
      end

      context 'form' do
        it 'does not create a grant if the form save fails' do
          allow(GrantSubmission::Form).to receive(:create).and_raise(StandardError)
          expect do
            GrantServices::New.call(grant: new_grant, user: grant_creator)
          end.not_to (change{Grant.count})
          expect(GrantPermission.count).to be 0
          expect(GrantSubmission::Form.count).to be 0
          expect(GrantSubmission::Section.count).to be 0
          expect(GrantSubmission::Question.count).to be 0
          expect(Criterion.count).to be 0
        end
      end

      context 'section' do
        it 'does not create a grant if the default section save fails' do
          allow_any_instance_of(GrantSubmission::Section).to receive(:save).and_raise(StandardError)
          expect do
            GrantServices::New.call(grant: new_grant, user: grant_creator)
          end.not_to (change{Grant.count})
          expect(GrantPermission.count).to be 0
          expect(GrantSubmission::Form.count).to be 0
          expect(GrantSubmission::Section.count).to be 0
          expect(GrantSubmission::Question.count).to be 0
        end
      end

      context 'question' do
        it 'does not create a grant if a default question save fails' do
          allow_any_instance_of(GrantSubmission::Question).to receive(:save).and_raise(StandardError)
          expect do
            GrantServices::New.call(grant: new_grant, user: grant_creator)
          end.not_to (change{Grant.count})
          expect(GrantPermission.count).to be 0
          expect(GrantSubmission::Form.count).to be 0
          expect(GrantSubmission::Section.count).to be 0
          expect(GrantSubmission::Question.count).to be 0
          expect(Criterion.count).to be 0
        end
      end
      context 'criteria' do
        it 'does not create a grant if criterion save fails' do
          allow(Criterion).to receive(:create).and_raise(StandardError)
          expect do
            GrantServices::New.call(grant: new_grant, user: grant_creator)
          end.not_to (change{Grant.count})
          expect(GrantPermission.count).to be 0
          expect(GrantSubmission::Form.count).to be 0
          expect(GrantSubmission::Section.count).to be 0
          expect(GrantSubmission::Question.count).to be 0
          expect(Criterion.count).to be 0
        end
      end
    end
  end
end
