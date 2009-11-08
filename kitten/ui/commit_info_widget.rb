
require File.join(File.dirname(__FILE__), 'diff_widget')
require File.join(File.dirname(__FILE__), 'ui_commit_info_widget')

class Ui_CommitInfoWidget
  DiffWidget = Kitten::Ui::DiffWidget
end

module Kitten
  module Ui
    class CommitInfoWidget < Qt::Widget
      def initialize(*args)
        super {}

        @ui = Ui_CommitInfoWidget.new
        @ui.setup_ui(self)

        yield(self) if block_given?
      end

      def clear()
        @ui.shaLabel.text = ''
        @ui.authorLabel.text = ''
        @ui.messageLabel.text = ''
        @ui.diffWidget.diff = ''
      end

      def updateView()
        unless commit
          clear
          return
        end

        @ui.shaLabel.text = commit.sha
        @ui.authorLabel.text = "#{commit.author.name} <#{commit.author.email}> #{commit.authored_date}"
        @ui.messageLabel.text = commit.message
        @ui.diffWidget.diff = unless commit.diffs.empty?
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