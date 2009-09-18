
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
    # Clones _their_repo_ into _my_repo_.
    # Options may include:
    # <tt>:bare => true</tt> if it should only do a bare clone
    #
    # Returns the Grit::Repo of the cloned repository.
    #
    # === Examples
    #   # Note: that the _my_repo_ location may not exists before
    #   Repo.clone('git://github.com/mojombo/grit.git', '~/projects/my_grit_clone')
    #   #=> #<Grit::Repo "~/projects/my_grit_clone/.git">
    #   Repo.clone('git://github.com/mojombo/grit.git', '~/projects/my_grit_clone.git', :bare => true)
    #   #=> #<Grit::Repo "~/projects/my_grit_clone.git">
    def self.clone(their_repo, my_repo, options = {})
      repo_path = my_repo
      bare_repo_path = options[:bare] ? repo_path : File.join(repo_path, '.git')

      Grit::Git.new(bare_repo_path).clone({:bare => true}, their_repo, bare_repo_path)
      repo = Grit::Repo.new(repo_path, :is_bare => options[:bare])

      repo.git.checkout({}, 'HEAD') unless options[:bare]

      repo
    end

    # Creates a fresh repository in _my_repo_.
    #
    # Returns the Grit::Repo of the new repository.
    #
    # === Examples
    #   # Note: that the _my_repo_ location may not exists before
    #   Repo.init('~/projects/foo')
    #   #=> #<Grit::Repo "~/projects/foo/.git">
    #   Repo.init('~/projects/bar.git', :bare => true)
    #   #=> #<Grit::Repo "~/projects/bar.git">
    def self.init(my_repo, options = {})
      repo_path = my_repo
      bare_repo_path = options[:bare] ? repo_path : File.join(repo_path, '.git')

      Grit::GitRuby::Repository.init(bare_repo_path, options[:bare])

      Grit::Repo.new(repo_path, :is_bare => options[:bare])
    end

    def stage_files(*files)
      self.git.add({}, *files)
    end

    def unstage_files(*files)
      self.git.reset({}, *['HEAD', '--', files].flatten)
    end

    include GritRepoQtExtender
  end
end
