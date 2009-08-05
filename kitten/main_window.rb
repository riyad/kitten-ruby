
require 'korundum4'

require 'kitten/git_branches_model'
require 'kitten/git_history_model'
require 'kitten/ui_main_window'

require 'rubygems'
require 'git'

module Kitten
  class MainWindow < KDE::MainWindow
      slots 'on_action_Open_triggered()',
            'on_historyBranchComboBox_currentIndexChanged(const QString&)'

      def initialize(*args)
        super
        @ui = Ui_MainWindow.new
        @ui.setupUi(self)
      end

      def loadModels()
        @history_model = GitHistoryModel.new(@repository, self)
        @branches_model = GitBranchesModel.new(@repository, self)

        @ui.historyTableView.model = @history_model
        @ui.historyBranchComboBox.model = @branches_model
        currentBranchIndex = @ui.historyBranchComboBox.findText(@repository.current_branch)
        @ui.historyBranchComboBox.currentIndex = currentBranchIndex
      end

      def on_action_Open_triggered()
        path = Qt::FileDialog.getExistingDirectory(self, "Select Git repository location")
        @repository = Git.open(path)
        loadModels()
      end

      def on_historyBranchComboBox_currentIndexChanged(currentBranch)
        @history_model.setBranch(currentBranch)
      end
  end
end
