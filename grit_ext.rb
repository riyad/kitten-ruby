
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
    include GritRepoQtExtender
  end
end
