
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

        open_repo_action = KDE::Action.new(self) do |a|
          a.text = i18n("Open repository")
          a.icon = KDE::Icon.new('folder-open')
          # TODO: make setting shortcuts work
          #a.shortcut = Qt::Key_F5
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
