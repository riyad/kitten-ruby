
require File.join(File.dirname(__FILE__), 'ui_stage_widget')

module Kitten
  module Ui
    class StageWidget < Qt::Widget

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
      end

      attr_accessor :repository
      def setRepository(repo)
        @repository = repo
        load_models
      end
    end
  end
end