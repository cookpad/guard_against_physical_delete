module GuardAgainstPhysicalDelete
  module Relation
    def self.included(base)
      base.prepend MethodOverrides
    end

    module MethodOverrides
      def delete_all(conditions = nil)
        unless klass.delete_permitted?
          raise GuardAgainstPhysicalDelete::PhysicalDeleteError, klass.name
        end

        super(conditions)
      end
    end
  end
end
