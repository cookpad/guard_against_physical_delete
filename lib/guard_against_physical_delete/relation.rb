module GuardAgainstPhysicalDelete
  module Relation
    def self.included(obj)
      obj.class_eval do
        def delete_all_with_check_permit(conditions = nil)
          unless @klass.delete_permitted?
            raise GuardAgainstPhysicalDelete::PhysicalDeleteError, @klass.name
          end
          delete_all_without_check_permit(conditions)
        end

        alias_method_chain :delete_all, :check_permit
      end
    end
  end
end
