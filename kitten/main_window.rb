
require 'kitten/git_branches_model'
require 'kitten/git_history_model'
require 'kitten/ui_main_window'

require 'git'

module Kitten
  class MainWindow < KDE::MainWindow
      slots 'on_action_Open_triggered()',
            'on_historyBranchComboBox_currentIndexChanged(const QString&)'

      def initialize(*args)
        super
        @ui = Ui_MainWindow.new
        @ui.setup_ui(self)

        @ui.action_Quit.connect(SIGNAL :triggered) { $kapp.quit }
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
        path = Qt::FileDialog.get_existing_directory(self, "Select Git repository location")
        self.repository = path
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
