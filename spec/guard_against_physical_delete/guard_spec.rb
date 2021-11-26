require 'spec_helper'
require 'countdownlatch'

describe GuardAgainstPhysicalDelete do
  shared_examples_for 'guard against physical delete' do
    let(:model) do
      model_class.create!
    end

    context 'when model has no deleted_at column' do
      let(:model_class) do
        Physical
      end

      it do
        expect { subject }.not_to raise_exception
      end
    end

    context 'when model has deleted_at column' do
      let(:model_class) do
        Logical
      end

      it do
        expect { subject }.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError)
      end
    end

    context 'when model has logical_delete_column' do
      let(:model_class) do
        RemovedAtLogical
      end

      it do
        expect { subject }.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError)
      end
    end
  end

  describe '.physical_delete' do
    let(:model1) do
      Logical.create!
    end

    let(:model2) do
      Logical.create!
    end

    it 'allows physical delete in given block' do
      expect do
        model2.class.physical_delete do
          model1.class.physical_delete do
            model1.delete
          end
          model2.delete
        end
      end.not_to raise_exception
    end

    context 'with multi threading' do
      it 'does not affect another thread' do
        latch = CountDownLatch.new 1

        threads = []
        threads << Thread.new do
          model1.class.physical_delete do
            latch.wait

            expect do
              model1.delete
            end.to_not raise_exception
            model1.class.connection.close if model1.class.connection.respond_to?('close')
          end
        end

        threads << Thread.new do
          expect do
            model2.delete
          end.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError)
          model1.class.connection.close if model1.class.connection.respond_to?('close')

          latch.countdown!
        end

        threads.map(&:join)
      end
    end
  end

  describe '.delete_all' do
    subject do
      model.class.delete_all
    end

    include_examples 'guard against physical delete'
  end

  describe '.delete_all on relation' do
    subject do
      model.class.where(id: model.id).delete_all
    end

    include_examples 'guard against physical delete'
  end

  describe '.destroy_all' do
    subject do
      model.class.destroy_all
    end

    include_examples 'guard against physical delete'
  end

  describe '.destroy_all on relation' do
    subject do
      model.class.where(id: model.id).destroy_all
    end

    include_examples 'guard against physical delete'
  end

  describe '#delete' do
    subject do
      model.delete
    end

    include_examples 'guard against physical delete'
  end

  describe '#destroy' do
    subject do
      model.destroy
    end

    include_examples 'guard against physical delete'
  end

  describe '#destroy!' do
    subject do
      model.destroy
    end

    include_examples 'guard against physical delete'
  end

  describe '#hard_delete' do
    subject do
      model.hard_delete
    end

    let!(:model) do
      Logical.create!
    end

    it 'destroys record in physical_delete block' do
      expect { subject }.to change { model.class.where(id: model.id).count }.from(1).to(0)
    end
  end

  describe '#soft_delete' do
    subject do
      model.soft_delete
    end

    let(:model) do
      Logical.create!
    end

    it 'sets current time to logical delete column' do
      expect { subject }.to change { model.reload.deleted_at }.from(nil)
    end

    it 'invokes after_save' do
      subject
      expect(model).to be_after_saved
    end

    it 'invokes validation' do
      model.name = 'too long name'
      expect { subject }.to raise_exception(ActiveRecord::RecordInvalid)
    end
  end
end
