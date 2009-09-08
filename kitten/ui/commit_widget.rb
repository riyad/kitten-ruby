
require File.join(File.dirname(__FILE__), 'ui_commit_widget')

module Kitten
  module Ui
    class CommitWidget < Qt::Widget
      slots 'commit()',
            'enableCommit()',
            'on_commitButton_clicked()'

      def clear()
        @ui.commitMessageTextEdit.clear
        @status = nil
      end

      def commit()
        if error
            KDE::MessageBox::sorry(self, i18n("You can't commit yet, because you have #{@error_message}."))
            return
        end

        message = @ui.commitMessageTextEdit.to_plain_text
        repository.commit(message)

        clear
        reload
      end

      def initialize(*args)
        super {}

        @ui = Ui_CommitWidget.new
        @ui.setupUi(self)

        connect(@ui.commitMessageTextEdit, SIGNAL('textChanged()'), self, SLOT('enableCommit()'))

        yield(self) if block_given?
      end

      def on_commitButton_clicked()
        commit
      end

      def reload()
        enableCommit
      end

      attr_accessor :repository
      def setRepository(repo)
        # TODO: disconnect old repo
        #self.disconnect(@repository.qt)

        @repository = repo

        connect(@repository.qt, SIGNAL('stageChanged()')) do
          @status = nil
          enable_commit
        end

        clear
        reload
      end

      protected

      def error()
        case
        when repo_status.staged_changes.empty?
          @error_message = 'no files staged'
          :no_staged_files
        when @ui.commitMessageTextEdit.to_plain_text.empty?
          @error_message = 'no commit message'
          :no_commit_message
        else
          @error_message = nil
          nil
        end
      end

      def enableCommit()
        @ui.commitErrorLabel.text = error ? "You have #{@error_message}." : nil
        @ui.commitButton.enabled = !error
      end

      private

      def repoStatus()
        @status ||= repository.status
      end
    end
  end
end
