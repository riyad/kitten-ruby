
require File.join(File.dirname(__FILE__), 'history_widget')
require File.join(File.dirname(__FILE__), 'stage_widget')
require File.join(File.dirname(__FILE__), 'ui_main_window')

class Ui_MainWindow
  HistoryWidget = Kitten::Ui::HistoryWidget
  StageWidget = Kitten::Ui::StageWidget
end

module Kitten
  module Ui
    class MainWindow < KDE::XmlGuiWindow
      slots 'open()',
            'reload()'

      def setupActions()
        KDE::StandardAction::quit($kapp, SLOT('quit()'), actionCollection);

      # commit
        commit_action = KDE::Action.new(self) do |a|
          a.text = i18n("Commit")
          a.icon = KDE::Icon.new('git-commit')
          # TODO: make setting shortcuts work
          #a.shortcut = Qt::CTRL + Qt::Key_Return
        end
        actionCollection.add_action('commit', commit_action)
        connect(commit_action, SIGNAL('triggered(bool)'), @ui.stageWidget, SLOT('commit()'))

        stage_file_action = KDE::Action.new(self) do |a|
          a.text = i18n("Stage File to Commit")
          a.icon = KDE::Icon.new('list-add')
          # TODO: make setting shortcuts work
          #a.shortcut = Qt::CTRL + Qt::Key_S
        end
        actionCollection.add_action('file_stage', stage_file_action)
        connect(stage_file_action, SIGNAL('triggered(bool)'), @ui.stageWidget, SLOT('stageFile()'))

        unstage_file_action = KDE::Action.new(self) do |a|
          a.text = i18n("Unstage File from Commit")
          a.icon = KDE::Icon.new('list-remove')
          # TODO: make setting shortcuts work
          #a.shortcut = Qt::CTRL + Qt::Key_U
        end
        actionCollection.add_action('file_unstage', unstage_file_action)
        connect(unstage_file_action, SIGNAL('triggered(bool)'), @ui.stageWidget, SLOT('unstageFile()'))

      # repository
        open_repo_action = KDE::Action.new(self) do |a|
          a.text = i18n("Open repository")
          a.icon = KDE::Icon.new('folder-open')
          # TODO: make setting shortcuts work
          #a.shortcut = Qt::CTRL + Qt::Key_O
        end
        actionCollection.add_action('repository_open', open_repo_action)
        connect(open_repo_action, SIGNAL('triggered(bool)'), self, SLOT('open()'))

        reload_repo_action = KDE::Action.new(self) do |a|
          a.text = i18n("Reload repository")
          a.icon = KDE::Icon.new('view-refresh')
          # TODO: make setting shortcuts work
          #a.shortcut = Qt::Key_F5
        end
        actionCollection.add_action('repository_reload', reload_repo_action)
        connect(reload_repo_action, SIGNAL('triggered(bool)'), self, SLOT('reload()'))
      end

      def setupUi()
        return if @ui

        @ui = Ui_MainWindow.new
        @ui.setupUi(self)

        setupActions

        setupGUI
      end

      def initialize(*args)
        super {}

        setupUi

        yield(self) if block_given?
      end

      def open()
        repos_dialog = RepositoriesDialog.new(self)
        repos_dialog.exec
        if repos_dialog.result == Qt::Dialog::Accepted
          path = repos_dialog.selected_repository_path
          self.repository = path
        end
      end

      def reload()
        @ui.historyWidget.reload
        @ui.stageWidget.reload
      end

      attr_accessor :repository
      def setRepository(repo_or_path)
        repo_or_path = Git.open(repo_or_path) unless repo_or_path.is_a?(Git::Base)
        @repository = repo_or_path

        @ui.historyWidget.repository = repository
        @ui.stageWidget.repository = repository
      end
    end
  end
end
