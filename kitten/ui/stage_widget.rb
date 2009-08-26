
require File.join(File.dirname(__FILE__), '../models/git_file_status_model')
require File.join(File.dirname(__FILE__), 'commit_widget')
require File.join(File.dirname(__FILE__), 'ui_stage_widget')

class Ui_StageWidget
  CommitWidget = Kitten::Ui::CommitWidget
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

        @ui.commitWidget.repository = repository
      end

      def on_stagedChangesView_clicked(index)
        @ui.unstagedChangesView.clear_selection
        status_file = @staged_files_model.map_to_status_file(index)
        show_file_status(status_file)
      end

      def on_stagedChangesView_doubleClicked(index)
        status_file = @staged_files_model.map_to_status_file(index)
        repository.unstage_file(status_file.path)
        reload
        new_index = @unstaged_files_model.map_to_index(status_file)
        @ui.unstagedChangesView.current_index = new_index
        show_file_status(status_file)
      end

      def on_unstagedChangesView_clicked(index)
        @ui.stagedChangesView.clear_selection
        status_file = @unstaged_files_model.map_to_status_file(index)
        show_file_status(status_file)
      end

      def on_unstagedChangesView_doubleClicked(index)
        status_file = @unstaged_files_model.map_to_status_file(index)
        repository.stage_file(status_file.path)
        reload
        new_index = @staged_files_model.map_to_index(status_file)
        @ui.stagedChangesView.current_index = new_index
        show_file_status(status_file)
      end

      def reload()
        @staged_files_model.reset
        @unstaged_files_model.reset
        @ui.commitWidget.reload
        clear_change_view
      end

      attr_accessor :repository
      def setRepository(repo)
        @repository = repo
        load_models
      end

      private

      def clearChangeView()
        @ui.diffDescription.title = ""
        @ui.diffBrowser.clear
      end

      def showFileStatus(status_file)
        if status_file.untracked?
          type = :blob
          data = status_file.blob.to_s
        else
          type = :diff
          data = status_file.diff.to_s
        end
        show_data(data, status_file.path, type)
      end

      def showData(data, file = nil, type = :blob)
        byte_array = Qt::ByteArray.new(data)
        if file && type == :blob
          type = KDE::MimeType.find_by_name_and_content(file, byte_array)
        else
          type = KDE::MimeType.find_by_content(byte_array)
        end
        binary = KDE::MimeType.isBufferBinaryData(byte_array)

        data = "Binary file (content not shown)" if binary

        @ui.diffDescription.title = type.name
        @ui.diffBrowser.text = data
      end
    end
  end
end
