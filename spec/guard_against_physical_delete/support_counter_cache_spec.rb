require 'spec_helper'

describe GuardAgainstPhysicalDelete do
  let(:parent) do
    Parent.create!
  end

  context 'when child is physically deleted' do
    subject do
      child.destroy
    end

    let!(:child) do
      parent.children.create!
    end

    it 'decrements counter' do
      expect { subject }.to change { parent.reload.children_count }.from(1).to(0)
    end
  end

  context 'when deleted_at child is physically deleted' do
    subject do
      child.delete
    end

    let!(:child) do
      parent.deleted_at_children.create!
    end

    it 'raises error' do
      expect { subject }.to raise_error(GuardAgainstPhysicalDelete::PhysicalDeleteError)
    end
  end

  context 'when removed_at child is physically deleted' do
    subject do
      child.delete
    end

    let!(:child) do
      parent.removed_at_children.create!
    end

    it 'raises error' do
      expect { subject }.to raise_error(GuardAgainstPhysicalDelete::PhysicalDeleteError)
    end
  end

  context 'when deleted_at child is logically deleted' do
    subject do
      child.soft_delete
    end

    let!(:child) do
      parent.deleted_at_children.create!
    end

    it 'decrements counter' do
      expect { subject }.to change { parent.reload.deleted_at_children_count }.from(1).to(0)
    end
  end

  context 'when removed_at child is logically deleted' do
    subject do
      child.soft_delete
    end

    let!(:child) do
      parent.removed_at_children.create!
    end

    it 'decrements counter' do
      expect { subject }.to change { parent.reload.removed_at_children_count }.from(1).to(0)
    end
  end

  context 'when logically deleted deleted_at child is updated' do
    subject do
      child.update!(name: 'dummy_name')
    end

    let!(:child) do
      parent.deleted_at_children.create!.tap(&:soft_delete)
    end

    it 'does not change counter' do
      expect { subject }.not_to change { parent.reload.deleted_at_children_count }
    end
  end

  context 'when logically deleted removed_at child is updated' do
    subject do
      child.update!(name: 'dummy_name')
    end

    let!(:child) do
      parent.removed_at_children.create!.tap(&:soft_delete)
    end

    it 'does not change counter' do
      expect { subject }.not_to change { parent.reload.removed_at_children_count }
    end
  end

  context 'when logically deleted deleted_at child is logically undeleted' do
    subject do
      child.update!(deleted_at: nil)
    end

    let!(:child) do
      parent.deleted_at_children.create!.tap(&:soft_delete)
    end

    it 'increments counter' do
      expect { subject }.to change { parent.reload.deleted_at_children_count }.from(0).to(1)
    end
  end

  context 'when logically deleted removed_at child is logically undeleted' do
    subject do
      child.update!(removed_at: nil)
    end

    let!(:child) do
      parent.removed_at_children.create!.tap(&:soft_delete)
    end

    it 'increments counter' do
      expect { subject }.to change { parent.reload.removed_at_children_count }.from(0).to(1)
    end
  end
end
