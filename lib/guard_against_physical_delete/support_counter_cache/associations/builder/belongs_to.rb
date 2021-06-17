module GuardAgainstPhysicalDelete
  module SupportCounterCache
    module Associations
      module Builder
        module BelongsTo
          def self.included(obj)
            class << obj
              prepend MethodOverrides

              private

              def add_logical_delete_counter_cache_methods(mixin)
                mixin.class_eval do
                  def belongs_to_counter_cache_after_logical_delete(reflection)
                    cache_column = reflection.counter_cache_column
                    delete_column = self.logical_delete_column
                    return unless saved_change_to_logical_delete_column?(delete_column)
                    return unless logical_delete_column_before_last_save(delete_column).nil?

                    record = send(reflection.name)
                    record.class.decrement_counter(cache_column, record.id) unless record.nil?
                  end

                  def belongs_to_counter_cache_after_revive(reflection)
                    cache_column = reflection.counter_cache_column
                    delete_column = self.logical_delete_column
                    return unless saved_change_to_logical_delete_column?(delete_column)
                    return if logical_delete_column_before_last_save(delete_column).nil?
                    return unless send(delete_column).nil?
                    record = send(reflection.name)
                    record.class.increment_counter(cache_column, record.id) unless record.nil?
                  end

                  if ActiveRecord.version < Gem::Version.new('5.1.0')
                    def saved_change_to_logical_delete_column?(delete_column)
                      __send__("#{delete_column}_changed?")
                    end

                    def logical_delete_column_before_last_save(delete_column)
                      __send__("#{delete_column}_was")
                    end
                  else
                    def saved_change_to_logical_delete_column?(delete_column)
                      __send__("saved_change_to_#{delete_column}?")
                    end

                    def logical_delete_column_before_last_save(delete_column)
                      __send__("#{delete_column}_before_last_save")
                    end
                  end
                end

                mixin.redefine_method("belongs_to_counter_cache_after_update_for_#{name}") do
                  # do nothing
                end if mixin.method_defined?("belongs_to_counter_cache_after_update_for_#{name}")
              end
            end
          end
        end

        module MethodOverrides
          private

          def add_counter_cache_methods(mixin)
            super(mixin)
            add_logical_delete_counter_cache_methods(mixin)
          end

          def add_counter_cache_callbacks(model, reflection)
            super(model, reflection)

            return unless model.logical_delete?

            model.after_update -> record do
              record.belongs_to_counter_cache_after_logical_delete(reflection)
              record.belongs_to_counter_cache_after_revive(reflection)
            end
          end
        end
      end
    end
  end
end
