
require 'kitten/ui_repositories_dialog'

require 'rubygems'
require 'git'

module Kitten
  class RepositoriesDialog < Qt::Dialog
      slots 'on_addButton_clicked()'

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
        # TODO: check whether repo dirs still contain repos
        # TODO: select last opened repo
      end

      def on_addButton_clicked()
        path = Qt::FileDialog.get_existing_directory(self, i18n("Select Git repository location"))
        if File.directory? File.join(path, '.git')
          found_items = @ui.repositoriesListWidget.find_items(path, Qt::MatchExactly)

          if found_items.empty?
            item = Qt::ListWidgetItem.new(KDE::Icon.new('repository'), path, @ui.repositoriesListWidget)
            @ui.repositoriesListWidget.add_item item
            @ui.repositoriesListWidget.current_row = @ui.repositoriesListWidget.count - 1
          else
            @ui.repositoriesListWidget.current_row = @ui.repositoriesListWidget.row(found_items[0])
          end
        else
          KDE::MessageBox::sorry(self, i18n("The selected directory does not contain a Git repository."))
        end
      end

      def selectedRepositoryPath()
        @ui.repositoriesListWidget.current_item.text
      end
  end
end
