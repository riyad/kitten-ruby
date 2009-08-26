
require File.join(File.dirname(__FILE__), '../models/git_branches_model')
require File.join(File.dirname(__FILE__), '../models/git_history_model')
require File.join(File.dirname(__FILE__), 'commit_info_widget')
require File.join(File.dirname(__FILE__), 'ui_history_widget')

class Ui_HistoryWidget
  CommitInfoWidget = Kitten::Ui::CommitInfoWidget
end

module Kitten
  module Ui
    class HistoryWidget < Qt::Widget
      slots 'on_branchComboBox_currentIndexChanged(const QString&)',
            'on_historyView_clicked(const QModelIndex&)'

      def createUi()
        @ui = Ui_HistoryWidget.new
        @ui.setup_ui(self)
      end

      def initialize(*args)
        super {}

        create_ui

        yield(self) if block_given?
      end

      def loadModels()
        @branches_model = Kitten::Models::GitBranchesModel.new(repository, self)
        @history_model = Kitten::Models::GitHistoryModel.new(repository, self)

        @ui.branchComboBox.model = @branches_model
        @ui.historyView.model = @history_model

        current_history_index = @history_model.index(0, 0)
        @ui.historyView.currentIndex = current_history_index
        on_historyView_clicked(current_history_index)

        show_current_branch
      end

      def on_branchComboBox_currentIndexChanged(current_branch)
        @history_model.branch = current_branch
      end

      def on_historyView_clicked(index)
        @ui.commitWidget.commit = @history_model.map_to_commit(index)
      end

      def reload()
        @branches_model.reset
        @history_model.reset

        show_current_branch
      end

      attr_accessor :repository
      def setRepository(repo)
        @repository = repo
        load_models
      end

      private

      def showCurrentBranch()
        current_branch_index = @ui.branchComboBox.find_text(repository.current_branch)
        @ui.branchComboBox.current_index = current_branch_index
      end
    end
  end
end