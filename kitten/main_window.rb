
require 'korundum4'

require 'kitten/git_history_model'
require 'kitten/ui_main_window'

module Kitten
  class MainWindow < KDE::MainWindow
      slots 'on_action_Open_triggered()'

      def initialize(*args)
        super
        @ui = Ui_MainWindow.new
        @ui.setupUi(self)
      end

      def loadModels()
        @ui.historyTableView.model = GitHistoryModel.new(@repository, self)
      end

      def on_action_Open_triggered()
        path = Qt::FileDialog.getExistingDirectory(self, "Select Git repository location")
        @repository = Git.open(path)
        loadModels()
      end
  end
end
