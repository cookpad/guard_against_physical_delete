module GuardAgainstPhysicalDelete
  module Base
    def self.included(obj)
      obj.extend ClassMethods
      obj.class_eval do
        class_attribute :logical_delete_column

        class << self
          alias_method :set_logical_delete_column, :logical_delete_column=
        end

        set_logical_delete_column :deleted_at
      end
      obj.send(:include, InstanceMethods)
    end

    module ClassMethods

      def physical_delete
        physical_delete_permission[self.name] += 1
        yield
      ensure
        physical_delete_permission[self.name] -= 1
      end

      def logical_delete?
        self.column_names.include? logical_delete_column.to_s
      end

      def delete_permitted?
        return true unless physical_delete_permission[self.name].zero?
        return false if logical_delete?
        return true
      end

      private

      THREAD_LOCAL_KEY = :__GuardAgainstPhysicalDelete__thread_local_permission__
      private_constant :THREAD_LOCAL_KEY

      def physical_delete_permission
        Thread.current[THREAD_LOCAL_KEY] ||= Hash.new { |h,k| h[k] = 0 }
      end
    end

    module InstanceMethods
      if ::ActiveRecord.version >= ::Gem::Version.new('5.2')
        def _delete_row
          unless self.class.delete_permitted?
            raise ::GuardAgainstPhysicalDelete::PhysicalDeleteError, self.class.name
          end

          super
        end
      end

      def hard_delete
        self.class.physical_delete { destroy }
      end

      def soft_delete
        self.__send__(:"#{self.class.logical_delete_column}=", Time.now)
        self.save!
      end
    end
  end
end
