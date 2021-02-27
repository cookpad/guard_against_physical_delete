require 'active_record'
require 'guard_against_physical_delete/physical_delete_error'
require 'guard_against_physical_delete/relation'
require 'guard_against_physical_delete/base'
require 'guard_against_physical_delete/support_counter_cache'

ActiveSupport.on_load :active_record do
  ActiveRecord::Base.send(:include, GuardAgainstPhysicalDelete::Base)
  ActiveRecord::Relation.send(:include, GuardAgainstPhysicalDelete::Relation)
  ActiveRecord::Associations::Builder::BelongsTo.send(:include, GuardAgainstPhysicalDelete::SupportCounterCache::Associations::Builder::BelongsTo)
end
