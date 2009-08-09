
require 'kitten/ui_repositories_dialog'

require 'rubygems'
require 'git'

module Kitten
  class RepositoriesDialog < Qt::Dialog

      def initialize(*args)
        super
        @ui = Ui::RepositoriesDialog.new
        @ui.setup_ui(self)

        @ui.repositorySearchLine.list_widget = @ui.repositoriesListWidget

        create_actions
      end

      def createActions()
        @ui.quitButton.icon = KDE::Icon.new('application-exit')
      end

      def selectedRepositoryPath()
        @ui.repositoriesListWidget.current_item.text
      end
  end
end
