module GuardAgainstPhysicalDelete
  module SupportCounterCache
    module Associations
      def self.included(obj)
        class << obj
          def add_counter_cache_callbacks_with_logical_delete(reflection)
            add_counter_cache_callbacks_without_logical_delete(reflection)
            return unless logical_delete?
            add_logical_delete_counter_cache_callback(reflection)
          end
          alias_method_chain :add_counter_cache_callbacks, :logical_delete

          def add_logical_delete_counter_cache_callback(reflection)
            cache_column = reflection.counter_cache_column

            logical_delete_method_name = "belongs_to_counter_cache_before_logical_delete_for_#{reflection.name}".to_sym
            define_method(logical_delete_method_name) do
              delete_column = self.logical_delete_column
              next unless send("#{delete_column}_changed?")
              next unless send("#{delete_column}_was").nil?
              association = send(reflection.name)
              association.class.decrement_counter(cache_column, association.id) unless association.nil?
            end

            revive_method_name = "belongs_to_counter_cache_before_revive_for_#{reflection.name}".to_sym
            define_method(revive_method_name) do
              delete_column = self.logical_delete_column
              next unless send("#{delete_column}_changed?")
              next if send("#{delete_column}_was").nil?
              next unless send(delete_column).nil?

              clear_association_cache
              association = send(reflection.name)
              association.class.increment_counter(cache_column, association.id) unless association.nil?
            end

            before_update(logical_delete_method_name, revive_method_name)
          end
        end
      end
    end
  end
end
