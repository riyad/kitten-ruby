
require File.join(File.dirname(__FILE__), 'ui_stage_widget')

module Kitten
  module Ui
    class StageWidget < Qt::Widget
      def initialize(*args)
        super {}

        @ui = Ui_StageWidget.new
        @ui.setup_ui(self)

        yield(self) if block_given?
      end
    end
  end
end