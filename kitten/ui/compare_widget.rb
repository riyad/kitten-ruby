
require File.join(File.dirname(__FILE__), '../models/git_branches_model')
require File.join(File.dirname(__FILE__), '../models/git_history_model')
require File.join(File.dirname(__FILE__), 'diff_widget')
require File.join(File.dirname(__FILE__), 'ui_compare_widget')

class Ui_CompareWidget
  DiffWidget = Kitten::Ui::DiffWidget
end

module Kitten
  module Ui
    class CompareWidget < Qt::Widget
      slots 'on_branchAComboBox_currentIndexChanged(const QString&)',
            'on_branchBComboBox_currentIndexChanged(const QString&)',
            'on_historyAView_clicked(const QModelIndex&)',
            'on_historyBView_clicked(const QModelIndex&)'

      def createUi()
        @ui = Ui_CompareWidget.new
        @ui.setup_ui(self)
      end

      def initialize(*args)
        super {}

        create_ui

        yield(self) if block_given?
      end

      def loadModels()
        @branches_model = Kitten::Models::GitBranchesModel.new(repository, self)
        @history_a_model = Kitten::Models::GitHistoryModel.new(repository, self)
        @history_b_model = Kitten::Models::GitHistoryModel.new(repository, self)

        @ui.branchAComboBox.model = @branches_model
        @ui.branchBComboBox.model = @branches_model

        @ui.historyAView.model = @history_a_model
        @ui.historyBView.model = @history_b_model

        current_history_index = @history_a_model.index(0, 0)
        @ui.historyAView.currentIndex = current_history_index
        @ui.historyBView.currentIndex = current_history_index
        on_historyAView_clicked(current_history_index)
        on_historyBView_clicked(current_history_index)

        show_current_branch
      end

      def on_branchAComboBox_currentIndexChanged(current_branch)
        @history_a_model.branch = current_branch
      end

      def on_branchBComboBox_currentIndexChanged(current_branch)
        @history_b_model.branch = current_branch
      end

      def on_historyAView_clicked(index)
        @commit_a = @history_a_model.map_to_commit(index)
        update_comparison
      end

      def on_historyBView_clicked(index)
        @commit_b = @history_b_model.map_to_commit(index)
        update_comparison
      end

      def reload()
        @branches_model.reset
        @history_a_model.reset
        @history_b_model.reset

        show_current_branch
      end

      attr_accessor :repository
      def setRepository(repo)
        @repository = repo
        load_models
      end

      private

      def showCurrentBranch()
        current_branch_index = @ui.branchAComboBox.find_text(repository.head.name)
        @ui.branchAComboBox.current_index = current_branch_index
        @ui.branchBComboBox.current_index = current_branch_index
        update_comparison
      end

      def updateComparison()
        @commit_a = repository.head.commit unless @commit_a
        @commit_b = repository.head.commit unless @commit_b

        @ui.diffWidget.diff = repository.diff(@commit_a.to_s, @commit_b.to_s)
      end
    end
  end
end