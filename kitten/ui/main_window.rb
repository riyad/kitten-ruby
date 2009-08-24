
require File.join(File.dirname(__FILE__), '../models/git_branches_model')
require File.join(File.dirname(__FILE__), '../models/git_history_model')
require File.join(File.dirname(__FILE__), 'commit_widget')
require File.join(File.dirname(__FILE__), 'stage_widget')
require File.join(File.dirname(__FILE__), 'ui_main_window')

class Ui_MainWindow
  CommitWidget = Kitten::Ui::CommitWidget
  StageWidget = Kitten::Ui::StageWidget
end

module Kitten
  module Ui
    class MainWindow < KDE::MainWindow
      slots 'on_action_Open_triggered()',
            'on_action_Reload_triggered()',
            'on_historyBranchComboBox_currentIndexChanged(const QString&)',
            'on_historyView_clicked(const QModelIndex&)'

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

      def loadModels()
        @history_model = Models::GitHistoryModel.new(repository, self)
        @branches_model = Models::GitBranchesModel.new(repository, self)

        @ui.historyView.model = @history_model
        @ui.historyBranchComboBox.model = @branches_model
        current_branch_index = @ui.historyBranchComboBox.find_text(repository.current_branch)
        @ui.historyBranchComboBox.current_index = current_branch_index

        current_history_index = @history_model.index(0, 0)
        @ui.historyView.currentIndex = current_history_index
        on_historyView_clicked(current_history_index)

        @ui.stageWidget.repository = repository
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
        @history_model.reset
        @branches_model.reset

        @ui.stageWidget.reload
      end

      def on_historyBranchComboBox_currentIndexChanged(current_branch)
        @history_model.branch = current_branch
      end

      def on_historyView_clicked(index)
        @ui.commitWidget.commit = @history_model.map_to_commit(index)
      end

      attr_accessor :repository
      def setRepository(repo_or_path)
        repo_or_path = Git.open(repo_or_path) unless repo_or_path.is_a?(Git::Base)
        @repository = repo_or_path
        load_models
      end
    end
  end
end
