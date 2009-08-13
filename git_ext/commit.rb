
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
        when :all:     branches = @base.branches
        else
          branches = [branches].flatten
        end

        children_shas = @base.lib.children_of(self.sha, branches)
        children_shas.map { |sha| Git::Object::Commit.new(@base, sha)}
      end
      alias_method :children_in, :children

      # true if this is a merge commit
      # (i.e. it has more than one parent)
      def merge?
        parents.size > 1
      end

      # shows the first line of the message
      def summary
        message[/[^\n]*/]
      end
    end
  end
end
