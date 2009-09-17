
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
  def commit_index(*args)
    super
    qt.logChanged
    qt.stageChanged
  end

  # overriden to emit the folowing signals when called:
  # stageChanged
  def stage_files(*args)
    super
    qt.stageChanged
  end

  # overriden to emit the folowing signals when called:
  # stageChanged
  def unstage_files(*args)
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
    def stage_files(*files)
      self.git.add({}, *files)
    end

    def unstage_files(*files)
      
      self.git.reset({}, *['HEAD', '--', files].flatten)
    end

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

    # Returns an array with the children of this commit.
    #
    # The default is to only look in the history of the current branch.
    # You can look for children in
    #     :current : the current branch (default)
    #     :all     : all branches
    #     [...]    : a list of branch names
    def children(branches = :current)
      case branches
      when :current: branches = [@repo.head]
      when :all:     branches = @repo.heads
      else
        if branches.is_a?(Enumerable)
          branches = branches.to_a
        else
          branches = [branches]
        end
      end

      branches.map! { |b| b.respond_to?(:name) ? b.name : b.to_s }

      # used for caching the result
      branches_key = branches.sort.join(' ')

      @children ||= {}
      if @children[branches_key]
        @children[branches_key]
      else
        children_shas = children_of(self.sha, branches)
        children = children_shas.map { |sha| @repo.commit(sha) }
        @children[branches_key] = children
      end
    end
    alias_method :children_on, :children

    # Returns true, when the commit has more than one child
    # i.e. when the commit is the parent of more than one commit
    # otherwise false
    #
    # You can also specify the branches to consider (see Commit#children).
    def branched?(branches = :current)
      children(branches).size > 1
    end
    alias_method :branched_on?, :branched?

    private
      # determines the children of a commit on the given branches and
      # returns an array with their SHAs.
      def children_of(commit, *branches)
        sha = commit.to_s
        branches = branches.flatten.map(&:to_s)

        opts = {:children => true}
        args = branches
        args << "^#{sha}^@"
        args << '--'

        rev_list = @repo.git.rev_list(opts, *args).split("\n")
        rev_index_for_commit = rev_list.find_index { |rev_line| rev_line =~ /^#{sha}/ }
        if rev_index_for_commit
          rev_line_for_commit = rev_list[rev_index_for_commit]

          children = rev_line_for_commit.split(' ')[1..-1]
        else
          []
        end
      end
  end

  class Diff
    def deletions
      diff.split("\n").count { |line| line.start_with?('-') } -1
    end
    def insertions
      diff.split("\n").count { |line| line.start_with?('+') } -1
    end
  end
end
