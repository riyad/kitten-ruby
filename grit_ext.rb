
class QtGritRepo < Qt::Object
  signals 'logChanged()',
          'stageChanged()'
end

module GritRepoQtExtension
  # returns a QtGitBase object to connect slots to
  def qt
    @qt ||= QtGritRepo.new
  end

  # overriden to emit the folowing signals when called:
  # logChanged, stageChanged
  def commit(*args)
    super
    qt.logChanged
    qt.stageChanged
  end

  # overriden to emit the folowing signals when called:
  # stageChanged
  def stage_file(*args)
    super
    qt.stageChanged
  end

  # overriden to emit the folowing signals when called:
  # stageChanged
  def unstage_file(*args)
    super
    qt.stageChanged
  end
end

module GritRepoQtExtender
  def self.included(base)
    base.send :alias_method, :initialize_without_qt, :initialize
    base.send :alias_method, :initialize, :initialize_with_qt
  end

  # initializes a Grit::Repo object and extends it with GritRepoQtExtension
  def initialize_with_qt(*args)
    initialize_without_qt(*args)
    extend(GritRepoQtExtension)
    self
  end
end

module Grit
  class Repo
    include GritRepoQtExtender
  end

  class Commit
    # the first line of the message
    def summary
      #@summary ||= message[/[^\n]*/]
      short_message
    end

    def merge?
      parents.size > 1
    end

#     # Returns an array with the children of this commit.
#     #
#     # The default is to only look in the history of the current branch.
#     # You can look for children in
#     #     :current : the current branch (default)
#     #     :all     : all branches
#     #     [...]    : a list of branch names
#     def children(branches = :current)
#       case branches
#       when :current: branches = [@base.current_branch]
#       when :all:     branches = @base.branches.to_a
#       else
#         if branches.is_a?(Enumerable)
#           branches = branches.to_a
#         else
#           branches = [branches]
#         end
#       end
# 
#       branches.map!(&:to_s)
# 
#       # used for caching the result
#       branches_key = branches.sort.join(' ')
# 
#       @children ||= {}
#       if @children[branches_key]
#         @children[branches_key]
#       else
#         children_shas = @base.lib.children_of(self.sha, branches)
#         children = children_shas.map { |sha| Git::Object::Commit.new(@base, sha)}
#         @children[branches_key] = children
#       end
#     end
#     alias_method :children_in, :children

    # Returns true, when the commit has more than one child
    # i.e. when the commit is the parent of more than one commit
    # otherwise false
    #
    # You can also specify the branches to consider (see Commit#children).
    def branched?(branches = :current)
      #children(branches).size > 1
      false
    end
    alias_method :branched_on?, :branched?
  end

  class Status
    def staged_changes
      to_a.select { |f| f.changes_staged? }
    end

    def unstaged_changes
      to_a.select { |f| f.changes_unstaged? }
    end

    class StatusFile
      def blob(type = nil)
        type = (changes_unstaged? ? :file : :index) unless type

        case type
        when :repo
          @base.blob(sha_repo) if sha_repo
        when :index
          @base.blob(sha_index) if sha_index
        when :file
          File.read(path) if File.exist?(path)
        end
      end

      def diff
        unless untracked?
          @diff ||= @base.git.diff({}, nil, nil)
          #Grit::Diff.new(@base, nil).path(path).cached(changes_staged?)
        end
      end

      def added?
        type == 'A'
      end

      def deleted?
        type == 'D'
      end

      def modified?
        type == 'M'
      end

      def untracked?
        untracked
      end

      def state
        s = untracked? ? 'U' : type
        {'A' => :added, 'D' => :deleted, 'M' => :modified, 'U' => :untracked}[s]
      end

      def changes_staged?
        type && false
      end

      def changes_unstaged?
        type && true
      end
    end
  end
end
