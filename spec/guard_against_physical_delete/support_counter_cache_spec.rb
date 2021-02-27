require 'spec_helper'

describe GuardAgainstPhysicalDelete do
  shared_examples_for 'counter cache' do
    let(:parent) { Parent.create! }
    let(:other_parent) { Parent.create! }

    it 'update counter_cache with soft_delete' do
      parent.reload
      expect(parent.send("#{children_association_name}_count")).to eq(2)

      child1.soft_delete

      parent.reload
      expect(parent.send("#{children_association_name}_count")).to eq(1)
    end

    it 'update counter_cache with hard_delete' do
      parent.reload
      expect(parent.send("#{children_association_name}_count")).to eq(2)
      child1.hard_delete
      parent.reload
      expect(parent.send("#{children_association_name}_count")).to eq(1)
    end

    it 'dont calc soft deleted record with updating' do
      child1.soft_delete
      child1.update_attributes(:name => 'alice')

      parent.reload
      expect(parent.send("#{children_association_name}_count")).to eq(1)
    end

    it 'calc revived record' do
      child1.soft_delete
      child1.update_attributes!(logical_delete_column_name => nil)
      parent.reload
      expect(parent.send("#{children_association_name}_count")).to eq(2)
    end

    it 'calc revived record with changing parent' do
      child1.soft_delete
      child1.update_attributes!(logical_delete_column_name => nil, :parent_id => other_parent.id)
      parent.reload
      expect(parent.send("#{children_association_name}_count")).to eq(1)

      other_parent.reload
      expect(other_parent.send("#{children_association_name}_count")).to eq(1)
    end
  end

  context 'deleted_at child' do
    let!(:child1) { parent.deleted_at_children.create! }
    let!(:child2) { parent.deleted_at_children.create! }
    let(:logical_delete_column_name) { 'deleted_at' }
    let(:children_association_name) { 'deleted_at_children' }

    it_should_behave_like 'counter cache'
  end

  context 'removed_at child' do
    let!(:child1) { parent.removed_at_children.create! }
    let!(:child2) { parent.removed_at_children.create! }
    let(:logical_delete_column_name) { 'removed_at' }
    let(:children_association_name) { 'removed_at_children' }

    it_should_behave_like 'counter cache'
  end

  context 'phisical delete' do
    let(:parent) { Parent.create! }
    let!(:child1) { parent.children.create! }
    let!(:child2) { parent.children.create! }

    it 'update counter_cache with hard_delete' do
      parent.reload
      expect(parent.children_count).to eq(2)
      child1.destroy
      parent.reload
      expect(parent.children_count).to eq(1)
    end
  end
end
