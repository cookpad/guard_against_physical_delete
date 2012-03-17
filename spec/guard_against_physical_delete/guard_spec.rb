require 'spec_helper'
require 'countdownlatch'

shared_examples 'preventing physical delete' do
  let!(:model)        { model_class.create!(:name => "name") }
  let(:another_model) { model_class.create!(:name => "name") }

  describe '#delete' do
    context 'without #physical_delete block' do
      it { expect { model.delete }.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError) }
    end

    context 'with #physical_delete block' do
      it { expect { model_class.physical_delete { model.delete } }.to_not raise_exception }

      it 'delete successufly with nesting block' do
        expect {
          model_class.physical_delete do
            model_class.physical_delete { model.delete }
            another_model.delete
          end
        }.to_not raise_exception
      end

      context 'multi threading' do
        it 'does not affect another thread' do
          latch = CountDownLatch.new 1

          threads = []
          threads << Thread.new do
            model_class.physical_delete do
              latch.wait

              expect { model.delete }.to_not raise_exception
              model_class.connection.close
            end
          end

          threads << Thread.new do
            expect { another_model.delete }.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError)
            model_class.connection.close

            latch.countdown!
          end

          threads.map(&:join)
        end
      end
    end
  end

  describe '#delete_all' do
    context 'without #physical_delete block' do
      it { expect { model_class.delete_all }.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError) }
    end

    context 'with #physical_delete block' do
      it { expect { model_class.physical_delete { model_class.delete_all } }.not_to raise_exception }
    end
  end

  describe '#hard_delete' do
    it 'do delete record' do
      expect { model.hard_delete }.to change { model_class.where(:id => model.id).count }.from(1).to(0)
    end
  end

  describe '#soft_delete' do
    it 'set timestamp to delete flag' do
      column = model_class.logical_delete_column
      expect { model.soft_delete }.to change { model_class.where("#{column} is not null").count }.from(0).to(1)
    end
  end

end

describe Logical do
  let(:model_class) { Logical }

  it_should_behave_like 'preventing physical delete'
end

describe RemovedAtLogical do
  before { RemovedAtLogical.logical_delete_column = :removed_at }
  let(:model_class) { RemovedAtLogical }

  it_should_behave_like 'preventing physical delete'
end

describe Physical do
  let(:model) { Physical.create!(:name => "name") }

  describe '#delete' do
    it { expect { model.delete }.not_to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError) }
  end
end

describe ActiveRecord::Relation do
  let!(:model) { Logical.create!(:name => "name") }

  subject { Logical.where(:id => model.id) }
  it { expect { subject.delete(model.id) }.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError) }
end
