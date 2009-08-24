
require File.join(File.dirname(__FILE__), 'history_widget')
require File.join(File.dirname(__FILE__), 'stage_widget')
require File.join(File.dirname(__FILE__), 'ui_main_window')

class Ui_MainWindow
  HistoryWidget = Kitten::Ui::HistoryWidget
  StageWidget = Kitten::Ui::StageWidget
end

module Kitten
  module Ui
    class MainWindow < KDE::MainWindow
      slots 'on_action_Open_triggered()',
            'on_action_Reload_triggered()'

      def createActions()
        @ui.action_Quit.connect(SIGNAL :triggered) { $kapp.quit }
      end

      def createUi()
        return if @ui

        @ui = Ui_MainWindow.new
        @ui.setup_ui(self)
      end

      def initialize(*args)
        super {}

        create_ui
        create_actions

        yield(self) if block_given?
      end

      def on_action_Open_triggered()
        repos_dialog = RepositoriesDialog.new(self)
        repos_dialog.exec
        if repos_dialog.result == Qt::Dialog::Accepted
          path = repos_dialog.selected_repository_path
          self.repository = path
        end
      end

      def on_action_Reload_triggered()
        reload
      end

      def reload()
        @ui.historyWidget.reload
        @ui.stageWidget.reload
      end

      attr_accessor :repository
      def setRepository(repo_or_path)
        repo_or_path = Git.open(repo_or_path) unless repo_or_path.is_a?(Git::Base)
        @repository = repo_or_path

        @ui.historyWidget.repository = repository
        @ui.stageWidget.repository = repository
      end
    end
  end
end
