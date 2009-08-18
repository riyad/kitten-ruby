
require File.join(File.dirname(__FILE__), '../models/git_unstaged_files_model')
require File.join(File.dirname(__FILE__), 'ui_stage_widget')

module Kitten
  module Ui
    class StageWidget < Qt::Widget
      slots 'on_unstagedChangesView_clicked(const QModelIndex&)'

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
        @unstaged_files_model = Models::GitUnstagedFilesModel.new(repository, self)
        @ui.unstagedChangesView.model = @unstaged_files_model
      end

      def reload()
        @unstaged_files_model.reset
      end

      def on_unstagedChangesView_clicked(index)
        status_file = @unstaged_files_model.map_to_status_file(index)
        @ui.diffBrowser.text = if status_file
                                  # shows old contents
                                  status_file.blob.contents
                                else
                                  ''
                                end
      end

      attr_accessor :repository
      def setRepository(repo)
        @repository = repo
        load_models
      end
    end
  end
end