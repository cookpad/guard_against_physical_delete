module GuardAgainstPhysicalDelete
  module SupportCounterCache
    module Associations
      module Builder
        module BelongsTo
          def self.included(obj)
            obj.class_eval do
              def add_counter_cache_callbacks_with_logical_delete(reflection)
                add_counter_cache_callbacks_without_logical_delete(reflection)
                return unless model.logical_delete?
                add_logical_delete_counter_cache_callback(reflection)
              end
              alias_method_chain :add_counter_cache_callbacks, :logical_delete

              def add_logical_delete_counter_cache_callback(reflection)
                cache_column = reflection.counter_cache_column
                name = self.name

                logical_delete_method_name = "belongs_to_counter_cache_after_logical_delete_for_#{name}".to_sym
                mixin.redefine_method(logical_delete_method_name) do
                  delete_column = self.logical_delete_column
                  next unless send("#{delete_column}_changed?")
                  next unless send("#{delete_column}_was").nil?
                  record = send(name)
                  record.class.decrement_counter(cache_column, record.id) unless record.nil?
                end

                mixin.redefine_method("belongs_to_counter_cache_after_update_for_#{name}") do
                  # do nothing
                end if mixin.method_defined?("belongs_to_counter_cache_after_update_for_#{name}")

                revive_method_name = "belongs_to_counter_cache_after_revive_for_#{name}".to_sym

                mixin.redefine_method(revive_method_name) do
                  delete_column = self.logical_delete_column
                  next unless send("#{delete_column}_changed?")
                  next if send("#{delete_column}_was").nil?
                  next unless send(delete_column).nil?
                  record = send(name)
                  record.class.increment_counter(cache_column, record.id) unless record.nil?
                end
                model.after_update(logical_delete_method_name, revive_method_name)
              end
            end
          end
        end
      end
    end
  end
end
