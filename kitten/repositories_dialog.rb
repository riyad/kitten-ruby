
require 'kitten/ui_repositories_dialog'

require 'rubygems'
require 'git'

module Kitten
  class RepositoriesDialog < Qt::Dialog
      slots 'on_addButton_clicked()'

      def accept()
        save_repositories

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
        repo_list = @ui.repositoriesListWidget

        config = KDE::Global.config
        cg = config.group "Repositories"

        repo_paths = cg.read_path_entry "List", []
        repo_paths.each do |path|
          add_repository path
          # TODO: check whether repo dirs still contain repos
        end

        last_selected_path = cg.read_path_entry "Last", nil

        if last_selected_path
          select_repository last_selected_path
        else
          select_repository 0
        end
      end

      def on_addButton_clicked()
        path = Qt::FileDialog.get_existing_directory(self, i18n("Select Git repository location"))

        # make sure the user has not cancelled the file dialog
        if path
          # make sure the directors it is a Git repo
          if File.directory? File.join(path, '.git')
            add_repository path
          else
            KDE::MessageBox::sorry self, i18n("The selected directory does not contain a Git repository.")
          end
        end
      end

      def reject()
        save_repositories

        super
      end

      def saveRepositories()
        repo_list = @ui.repositoriesListWidget

        config = KDE::Global.config
        cg = config.group "Repositories"

        repo_paths = []
        0.upto(repo_list.count-1) do |row|
          repo_paths << repo_list.item(row).text
        end

        cg.write_path_entry "List", repo_paths

        cg.write_path_entry "Last", selected_repository_path

        config.sync
      end

      def selectedRepositoryPath()
        @ui.repositoriesListWidget.current_item.text
      end

      private

      def addRepository(path)
        repo_list = @ui.repositoriesListWidget

        found_items = repo_list.find_items(path, Qt::MatchExactly)

        # make sure we only add a repo once
        if found_items.empty?
          item = Qt::ListWidgetItem.new KDE::Icon.new('repository'), path, repo_list
          repo_list.add_item item
        end

        select_repository path
      end

      def selectRepository(item_or_path_or_row)
        repo_list = @ui.repositoriesListWidget
        if item_or_path_or_row.is_a? Qt::ListWidgetItem
          repo_list.current_item = item_or_path_or_row
        elsif item_or_path_or_row.is_a? Integer
          repo_list.current_row = 0
        else
          found_items = repo_list.find_items(item_or_path_or_row.to_s, Qt::MatchExactly)
          repo_list.current_row = repo_list.row found_items[0] unless found_items.empty?
        end
      end
  end
end
