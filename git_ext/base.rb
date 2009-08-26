
class QtGitBase < Qt::Object
  signals 'logChanged()',
          'stageChanged()'
end

module GitBaseQtExtension
  # returns a QtGitBase object to connect slots to
  def qt
    @qt ||= QtGitBase.new
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

module GitBaseQtExtender
  def self.included(base)
    base.send :alias_method, :initialize_without_qt, :initialize
    base.send :alias_method, :initialize, :initialize_with_qt
  end

  # initializes a Git::Base object and extends it with GitBaseQtExtension
  def initialize_with_qt(*args)
    initialize_without_qt(*args)
    extend(GitBaseQtExtension)
    self
  end
end

module Git
  class Base
    include GitBaseQtExtender
  end
end
