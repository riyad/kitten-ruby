
require 'kitten/ui_repositories_dialog'

require 'rubygems'
require 'git'

module Kitten
  class RepositoriesDialog < Qt::Dialog

      def accept()
        # TODO: save list of repos
        # TODO: remember opened repo
        super
      end

      def initialize(*args)
        super
        @ui = Ui::RepositoriesDialog.new
        @ui.setup_ui(self)

        @ui.repositorySearchLine.list_widget = @ui.repositoriesListWidget

        create_actions

        load_repositories
      end

      def createActions()
        @ui.newButton.icon  = KDE::Icon.new('folder-new')
        @ui.addButton.icon  = KDE::Icon.new('list-add')
        @ui.removeButton.icon = KDE::Icon.new('list-remove')
        @ui.openButton.icon = KDE::Icon.new('document-open-folder')
        if parent
          @ui.quitButton.icon = KDE::Icon.new('dialog-cancel')
          @ui.quitButton.text = "Cancel"
        else
          @ui.quitButton.icon = KDE::Icon.new('application-exit')
          @ui.quitButton.text = "Exit"
        end
      end

      def loadRepositories()
        # TODO: load list of repos
        # TODO: select last opened repo
      end

      def selectedRepositoryPath()
        @ui.repositoriesListWidget.current_item.text
      end
  end
end
