
require File.join(File.dirname(__FILE__), '../models/git_file_status_model')
require File.join(File.dirname(__FILE__), 'commit_widget')
require File.join(File.dirname(__FILE__), 'file_status_widget')
require File.join(File.dirname(__FILE__), 'ui_stage_widget')

class Ui_StageWidget
  CommitWidget = Kitten::Ui::CommitWidget
  FileStatusWidget = Kitten::Ui::FileStatusWidget
end

module Kitten
  module Ui
    class StageWidget < Qt::Widget
      slots 'on_stagedChangesView_clicked(const QModelIndex&)',
            'on_stagedChangesView_doubleClicked(const QModelIndex&)',
            'on_unstagedChangesView_clicked(const QModelIndex&)',
            'on_unstagedChangesView_doubleClicked(const QModelIndex&)'

      def createUi()
        @ui = Ui_StageWidget.new
        @ui.setup_ui(self)
      end

      def initialize(*args)
        super {}

        create_ui

        yield(self) if block_given?
      end

      def loadModels()
        @staged_files_model = Kitten::Models::GitFileStatusModel.new(repository, :staged, self)
        @ui.stagedChangesView.model = @staged_files_model

        @unstaged_files_model = Kitten::Models::GitFileStatusModel.new(repository, :unstaged, self)
        @ui.unstagedChangesView.model = @unstaged_files_model

        @ui.fileStatusWidget.repository = repository
        @ui.commitWidget.repository = repository
      end

      def on_stagedChangesView_clicked(index)
        @ui.unstagedChangesView.clear_selection
        status_file = @staged_files_model.map_to_status_file(index)
        @ui.fileStatusWidget.file_status = status_file
      end

      def on_stagedChangesView_doubleClicked(index)
        status_file = @staged_files_model.map_to_status_file(index)
        repository.unstage_file(status_file.path)

        new_index = @unstaged_files_model.map_to_index(status_file)
        @ui.unstagedChangesView.current_index = new_index
      end

      def on_unstagedChangesView_clicked(index)
        @ui.stagedChangesView.clear_selection
        status_file = @unstaged_files_model.map_to_status_file(index)
        @ui.fileStatusWidget.file_status = status_file
      end

      def on_unstagedChangesView_doubleClicked(index)
        status_file = @unstaged_files_model.map_to_status_file(index)
        repository.stage_file(status_file.path)

        new_index = @staged_files_model.map_to_index(status_file)
        @ui.stagedChangesView.current_index = new_index
      end

      def reload()
        @staged_files_model.reset
        @unstaged_files_model.reset
        @ui.fileStatusWidget.reload
        @ui.commitWidget.reload
      end

      attr_accessor :repository
      def setRepository(repo)
        @repository = repo
        load_models
      end
    end
  end
end
