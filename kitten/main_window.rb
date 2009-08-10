
require 'kitten/git_branches_model'
require 'kitten/git_history_model'
require 'kitten/ui_main_window'

require 'git'

module Kitten
  class MainWindow < KDE::MainWindow
      slots 'on_action_Open_triggered()',
            'on_historyBranchComboBox_currentIndexChanged(const QString&)'

      def createActions()
        @ui.action_Quit.connect(SIGNAL :triggered) { $kapp.quit }
      end

      def createUi()
        return if @ui

        @ui = Ui::MainWindow.new
        @ui.setup_ui(self)
      end

      def initialize(*args)
        super {}

        create_ui
        create_actions

        yield self if block_given?
      end

      def loadModels()
        @history_model = GitHistoryModel.new(repository, self)
        @branches_model = GitBranchesModel.new(repository, self)

        @ui.historyTableView.model = @history_model
        @ui.historyBranchComboBox.model = @branches_model
        current_branch_index = @ui.historyBranchComboBox.find_text(repository.current_branch)
        @ui.historyBranchComboBox.current_index = current_branch_index
      end

      def on_action_Open_triggered()
        repos_dialog = RepositoriesDialog.new(self)
        repos_dialog.exec
        if repos_dialog.result == Qt::Dialog::Accepted
          path = repos_dialog.selected_repository_path
          self.repository = path
        end
      end

      def on_historyBranchComboBox_currentIndexChanged(current_branch)
        @history_model.branch = current_branch
      end

      attr_accessor :repository
      def setRepository(repo_or_path)
        repo_or_path = Git.open(repo_or_path) unless repo_or_path.is_a? Git::Base
        @repository = repo_or_path
        load_models
      end
  end
end
