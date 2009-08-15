
require File.join(File.dirname(__FILE__), 'ui_commit_widget')

module Kitten
  class CommitWidget < Qt::Widget
    def initialize(*args)
      super {}

      @ui = Ui::CommitWidget.new
      @ui.setup_ui(self)

      yield if block_given?
    end

    def update_view()
    end

    attr_accessor :commit
    def setCommit(commit)
      @commit = commit
      update_view
    end
  end
end