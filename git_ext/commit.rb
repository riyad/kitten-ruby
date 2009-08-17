
module Git
  class Object
    class Commit
      # Returns true, when the commit has more than one child
      # i.e. when the commit is the parent of more than one commit
      # otherwise false
      #
      # You can also specify the branches to consider (see the Commit#children).
      def branched?(branches = :current)
        children(branches).size > 1
      end
      alias_method :branched_on?, :branched?

      # Returns an array with the children of this commit.
      #
      # The default is to only look in the history of the current branch.
      # You can look for children in
      #     :current : the current branch (default)
      #     :all     : all branches
      #     [...]    : a list of branch names
      def children(branches = :current)
        case branches
        when :current: branches = [@base.current_branch]
        when :all:     branches = @base.branches.to_a
        else
          if branches.is_a?(Enumerable)
            branches = branches.to_a
          else
            branches = [branches]
          end
        end

        branches.map!(&:to_s)
        branches_key = branches.sort.join(' ')

        @children ||= {}
        if @children[branches_key]
          @children[branches_key]
        else
          children_shas = @base.lib.children_of(self.sha, branches)
          children = children_shas.map { |sha| Git::Object::Commit.new(@base, sha)}
          @children[branches_key] = children
        end
      end
      alias_method :children_in, :children

      # true if this is a merge commit
      # (i.e. it has more than one parent)
      def merge?
        parents.size > 1
      end

      # shows the first line of the message
      def summary
        @summary ||= message[/[^\n]*/]
      end
    end
  end
end
