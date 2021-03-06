
require File.join(File.dirname(__FILE__), 'clone_repository_dialog')
require File.join(File.dirname(__FILE__), 'ui_repositories_dialog')

module Kitten
  module Ui
    class RepositoriesDialog < Qt::Dialog
      slots 'on_repositoriesListWidget_currentTextChanged(const QString&)',
            'on_addButton_clicked()',
            'on_cloneButton_clicked()',
            'on_newButton_clicked()',
            'on_removeButton_clicked()'

      def accept()
        save_repositories

        super
      end

      def initialize(*args)
        super
        @ui = Ui_RepositoriesDialog.new
        @ui.setup_ui(self)

        self.window_icon = Qt::Icon.new(':/icons/16x16/places/repository')

        @ui.repositorySearchLine.list_widget = @ui.repositoriesListWidget

        create_actions

        load_repositories
      end

      def createActions()
        if parent
          @ui.quitButton.icon = Qt::Icon.new(':/icons/16x16/actions/dialog-cancel')
          @ui.quitButton.text = "Cancel"
        else
          @ui.quitButton.icon = Qt::Icon.new(':/icons/16x16/actions/application-exit')
          @ui.quitButton.text = "Exit"
        end
      end

      def loadRepositories()
        repo_list = @ui.repositoriesListWidget

        config = KDE::Global.config
        cg = config.group("Repositories")

        repo_paths = cg.read_path_entry("List", [])
        repo_paths.each do |path|
          add_repository(path)
          # TODO: check whether repo dirs still contain repos
        end

        last_selected_path = cg.read_path_entry("Last", nil)

        if last_selected_path
          select_repository(last_selected_path)
        else
          select_repository(0)
        end
      end

      def on_repositoriesListWidget_currentTextChanged(text)
        @ui.removeButton.enabled = text
        @ui.openButton.enabled = text
      end

      def on_addButton_clicked()
        path = Qt::FileDialog.get_existing_directory(self, i18n("Select Git repository location"))

        # make sure the user has not cancelled the file dialog
        if path
          # make sure the directory is a Git repo
          if Grit::Repo.contains_repository?(path)
            add_repository(path)
          else
            KDE::MessageBox::sorry(self, i18n("The selected directory does not contain a Git repository."))
          end
        end
      end

      def on_cloneButton_clicked()
        clone_dialog = Kitten::Ui::CloneRepositoryDialog.new(self)
        clone_dialog.exec
        if clone_dialog.result == Qt::Dialog::Accepted
          add_repository(clone_dialog.repository_path)
        end
      end

      def on_newButton_clicked()
        path = Qt::FileDialog.get_existing_directory(self, i18n("Select a location for the new Git repository"))

        # make sure the user has not cancelled the file dialog
        if path
          # make sure the directory exists and is empty
          if Dir.entries(path) == %w{. ..}
            Grit::Repo.init(path)
            add_repository(path)
          else
            KDE::MessageBox::sorry(self, i18n("Can not create a Git repository in #{path}.\nThe directory is not empty."))
          end
        end
      end

      def on_removeButton_clicked()
        repo_list = @ui.repositoriesListWidget

        row = repo_list.current_row
        repo_list.take_item(row)
        select_repository(row-1)
      end

      def reject()
        save_repositories

        super
      end

      def saveRepositories()
        repo_list = @ui.repositoriesListWidget

        config = KDE::Global.config
        cg = config.group("Repositories")

        repo_paths = []
        0.upto(repo_list.count-1) do |row|
          repo_paths << repo_list.item(row).text
        end

        cg.write_path_entry("List", repo_paths)

        cg.write_path_entry("Last", selected_repository_path)

        config.sync
      end

      def selectedRepositoryPath()
        @ui.repositoriesListWidget.current_item.text if @ui.repositoriesListWidget.current_item
      end

      private

      def addRepository(path)
        repo_list = @ui.repositoriesListWidget

        found_items = repo_list.find_items(path, Qt::MatchExactly)

        # make sure we only add a repo once
        if found_items.empty?
          item = Qt::ListWidgetItem.new(Qt::Icon.new(':/icons/16x16/places/repository'), path, repo_list)
          repo_list.add_item(item)
        end

        select_repository(path)
      end

      def selectRepository(item_or_path_or_row)
        repo_list = @ui.repositoriesListWidget
        if item_or_path_or_row.is_a?(Qt::ListWidgetItem)
          repo_list.current_item = item_or_path_or_row
        elsif item_or_path_or_row.is_a?(Integer)
          repo_list.current_row = 0
        else
          found_items = repo_list.find_items(item_or_path_or_row.to_s, Qt::MatchExactly)
          repo_list.current_row = repo_list.row(found_items[0]) unless found_items.empty?
        end
      end
    end
  end
end
