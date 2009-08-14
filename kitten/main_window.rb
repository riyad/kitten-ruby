
require 'git'

require File.join(File.dirname(__FILE__), 'git_branches_model')
require File.join(File.dirname(__FILE__), 'git_history_model')
require File.join(File.dirname(__FILE__), 'ui_main_window')

module Kitten
  class MainWindow < KDE::MainWindow
      slots 'on_action_Open_triggered()',
            'on_historyBranchComboBox_currentIndexChanged(const QString&)',
            'on_historyTreeView_clicked(const QModelIndex&)'

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

        yield(self) if block_given?
      end

      def loadModels()
        @history_model = GitHistoryModel.new(repository, self)
        @branches_model = GitBranchesModel.new(repository, self)

        @ui.historyTreeView.model = @history_model
        @ui.historyBranchComboBox.model = @branches_model
        current_branch_index = @ui.historyBranchComboBox.find_text(repository.current_branch)
        @ui.historyBranchComboBox.current_index = current_branch_index

        current_history_index = @history_model.index(0, 0)
        @ui.historyTreeView.currentIndex = current_history_index
        on_historyTreeView_clicked(current_history_index)
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

      def on_historyTreeView_clicked(index)
        commit = @history_model.map_to_commit(index)
        historyDiff = "SHA: #{commit.sha}\n" +
                      "Author: #{commit.author.name} <#{commit.author.email}> #{commit.author_date}\n" +
                      "Message: #{commit.message}\n" +
                      "\n" +
                      (commit.parents.empty? ? "" : commit.diff_parent.to_s)
        @ui.historyDiffTextEdit.text = historyDiff
      end

      attr_accessor :repository
      def setRepository(repo_or_path)
        repo_or_path = Git.open(repo_or_path) unless repo_or_path.is_a?(Git::Base)
        @repository = repo_or_path
        load_models
      end
  end
end
