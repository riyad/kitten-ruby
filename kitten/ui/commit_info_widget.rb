
require File.join(File.dirname(__FILE__), 'ui_commit_info_widget')

module Kitten
  module Ui
    class CommitInfoWidget < Qt::Widget
      def initialize(*args)
        super {}

        @ui = Ui_CommitInfoWidget.new
        @ui.setup_ui(self)

        yield(self) if block_given?
      end

      def updateView()
        @ui.shaLabel.text = commit.sha
        @ui.authorLabel.text = "#{commit.author.name} <#{commit.author.email}> #{commit.authored_date}"
        @ui.messageLabel.text = commit.message
        @ui.diffTextBrowser.text = unless commit.diffs.empty?
                                      commit.diffs.map(&:diff).join("\n")
                                    else
                                      ''
                                  end
      end

      attr_accessor :commit
      def setCommit(commit)
        @commit = commit
        update_view
      end
    end
  end
end