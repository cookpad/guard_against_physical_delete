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
                  def adjust_counter_caches_for_logical_deletion(reflection)
                    if attribute_before_last_save(logical_delete_column).nil? && attribute(logical_delete_column)
                      reflection.klass.decrement_counter(
                        reflection.counter_cache_column,
                        attribute_before_last_save(reflection.foreign_key)
                      )
                    elsif attribute_before_last_save(logical_delete_column) && attribute(logical_delete_column).nil?
                      reflection.klass.increment_counter(
                        reflection.counter_cache_column,
                        attribute_before_last_save(reflection.foreign_key)
                      )
                    end
                  end

                  # Polyfill for Rails < 5.1, not that it's perfectly compatible.
                  if ActiveRecord.version < Gem::Version.new('5.1.0')
                    # @param [#to_s] attr_name
                    # @return [Object]
                    def attribute_before_last_save(attr_name)
                      __send__("#{attr_name}_was")
                    end

                    # @param [#to_s] attr_name
                    # @return [Boolean]
                    def saved_change_to_attribute?(attr_name)
                      __send__("#{attr_name}_changed?")
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

          def add_counter_cache_callbacks(model, reflection)
            super(model, reflection)

            return unless model.logical_delete?

            add_logical_delete_counter_cache_methods(model)

            model.after_update -> record do
              record.adjust_counter_caches_for_logical_deletion(reflection)
            end
          end
        end
      end
    end
  end
end
