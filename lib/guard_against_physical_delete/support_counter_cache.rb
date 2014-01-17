if ActiveRecord::VERSION::STRING >= "3.2"
  require 'guard_against_physical_delete/support_counter_cache/3.2_and_4.0/associations/builder/belongs_to'
  ActiveRecord::Associations::Builder::BelongsTo.send(:include, GuardAgainstPhysicalDelete::SupportCounterCache::Associations::Builder::BelongsTo)
elsif ActiveRecord::VERSION::STRING == "3.0.10"
  require 'guard_against_physical_delete/support_counter_cache/3.0.10/associations'
  ActiveRecord::Base.send(:include, GuardAgainstPhysicalDelete::SupportCounterCache::Associations)
else
  raise "guard_against_physical_delete doesn't support ActiveRecord version #{ActiveRecord::VERSION::STRING}"
end
