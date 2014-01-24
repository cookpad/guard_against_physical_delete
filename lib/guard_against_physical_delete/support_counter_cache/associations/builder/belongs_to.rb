module GuardAgainstPhysicalDelete
  module SupportCounterCache
    module Associations
      module Builder
        module BelongsTo
          def self.included(obj)
            class << obj
              private
              def add_counter_cache_methods_with_logical_delete(mixin)
                add_counter_cache_methods_without_logical_delete mixin
                return unless mixin.logical_delete?
                add_logical_delete_counter_cache_methods(mixin)
              end
              alias_method_chain :add_counter_cache_methods, :logical_delete

              def add_logical_delete_counter_cache_methods(mixin)
                mixin.class_eval do
                  def belongs_to_counter_cache_after_logical_delete(reflection)
                    cache_column = reflection.counter_cache_column
                    delete_column = self.logical_delete_column
                    return unless send("#{delete_column}_changed?")
                    return unless send("#{delete_column}_was").nil?

                    record = send(reflection.name)
                    record.class.decrement_counter(cache_column, record.id) unless record.nil?
                  end

                  def belongs_to_counter_cache_after_revive(reflection)
                    cache_column = reflection.counter_cache_column
                    delete_column = self.logical_delete_column
                    return unless send("#{delete_column}_changed?")
                    return if send("#{delete_column}_was").nil?
                    return unless send(delete_column).nil?
                    record = send(reflection.name)
                    record.class.increment_counter(cache_column, record.id) unless record.nil?
                  end
                end
                mixin.redefine_method("belongs_to_counter_cache_after_update_for_#{name}") do
                  # do nothing
                end if mixin.method_defined?("belongs_to_counter_cache_after_update_for_#{name}")
              end

              def add_counter_cache_callbacks_with_logical_delete(model, reflection)
                add_counter_cache_callbacks_without_logical_delete model, reflection

                model.after_update lambda { |record|
                  record.belongs_to_counter_cache_after_logical_delete(reflection)
                  record.belongs_to_counter_cache_after_revive(reflection)
                }
              end
              alias_method_chain :add_counter_cache_callbacks, :logical_delete
            end
          end
        end
      end
    end
  end
end
