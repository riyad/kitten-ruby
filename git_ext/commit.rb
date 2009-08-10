
require 'git'

module Git
  class Object
    class Commit
      def merge?
        parents.size > 1
      end
    end
  end
end
