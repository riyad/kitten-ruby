
require File.join(File.dirname(__FILE__), '../models/git_file_status_model')
require File.join(File.dirname(__FILE__), 'ui_stage_widget')

module Kitten
  module Ui
    class StageWidget < Qt::Widget
      slots 'on_stagedChangesView_clicked(const QModelIndex&)',
            'on_unstagedChangesView_clicked(const QModelIndex&)'

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
      end

      def reload()
        @staged_files_model.reset
        @unstaged_files_model.reset
      end

      def on_stagedChangesView_clicked(index)
        @ui.unstagedChangesView.clear_selection
        status_file = @staged_files_model.map_to_status_file(index)
        show_file_status(status_file)
      end

      def on_unstagedChangesView_clicked(index)
        @ui.stagedChangesView.clear_selection
        status_file = @unstaged_files_model.map_to_status_file(index)
        show_file_status(status_file)
      end

      attr_accessor :repository
      def setRepository(repo)
        @repository = repo
        load_models
      end

      private

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
