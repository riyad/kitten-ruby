
module Git
  class Object
    class Commit
      def branched?
        false
      end

      def merge?
        parents.size > 1
      end
    end
  end
end
