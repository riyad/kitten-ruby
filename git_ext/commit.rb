
module Git
  class Object
    class Commit
      def branched?
        false
      end

      def merge?
        parents.size > 1
      end

      # shows the first line of the commit's message
      def summary
        message[/[^\n]*/]
      end
    end
  end
end
