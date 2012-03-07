require 'spec_helper'
require 'thread'

describe "Guard against physical delete" do
  let(:physical) { Physical.create!(:name => "name") }
  let(:logical) { Logical.create!(:name => "name") }
  let(:logical2) { Logical.create!(:name => "name") }
  let(:removed) { RemovedAtLogical.create!(:name => "name") }
  describe 'logical delete table' do
    it "raise exception" do
      expect { logical.delete }.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError) 
    end

    it 'raise exception by relation' do
      expect { Logical.where(:id => logical.id).delete(logical.id) }.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError) 
    end

    it 'raise exception with delete_all' do
      expect { Logical.delete_all }.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError) 
    end

    it 'permit delete with thread' do
      Logical.physical_delete do
        expect { logical.delete }.to_not raise_exception
      end
    end

    it 'nested permit delete' do
      Logical.physical_delete do
        Logical.physical_delete do
          expect { logical.delete }.to_not raise_exception
        end
        expect { logical2.delete }.to_not raise_exception
      end
    end

    it 'permit with thread' do
      threads = []
      mutex = Mutex.new
      threads << Thread.new do
        mutex.lock
        Logical.physical_delete do
          mutex.unlock
          expect { logical.delete }.to_not raise_exception
          mutex.lock
        end
        mutex.unlock
        Logical.connection.close
      end

      threads << Thread.new do
        mutex.synchronize do
          expect { logical2.delete }.to raise_exception;
          Logical.connection.close
        end
      end
      threads.map(&:join)
    end


    it 'specified column' do
      RemovedAtLogical.logical_delete_column = :removed_at
      expect { removed.delete }.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError) 
      expect { logical.delete }.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError) 
    end
  end

  describe 'physical delete table' do
    it "no raise exception" do
      expect { physical.delete }.to_not raise_exception
    end

    it 'conditional delete' do
      physical1 = Physical.create!(:name => "name") 
      physical2 = Physical.create!(:name => "name") 
      expect {
        Physical.delete_all(:id => physical1.id)
      }.to change(Physical, :count).from(2).to(1)
    end
  end

  describe 'relation' do
    let(:physical_has_logical) { Physical.create!(:name => "name", :logical_id => logical.id) }

    it 'raise exception by destroy' do
      expect { physical_has_logical.destroy }.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError) 
    end

    it 'no raise exception by delete' do
      expect { physical_has_logical.destroy }.to raise_exception(GuardAgainstPhysicalDelete::PhysicalDeleteError) 
    end
  end
end
