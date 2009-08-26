
require File.join(File.dirname(__FILE__), 'ui_commit_widget')

module Kitten
  module Ui
    class CommitWidget < Qt::Widget
      slots 'enableCommit()',
            'on_commitButton_clicked()'

      def initialize(*args)
        super {}

        @ui = Ui_CommitWidget.new
        @ui.setupUi(self)

        connect(@ui.commitMessageTextEdit, SIGNAL('textChanged()'), self, SLOT('enableCommit()'))

        yield(self) if block_given?
      end

      def on_commitButton_clicked()
        message = @ui.commitMessageTextEdit.to_plain_text
        repository.commit(message)

        @ui.commitMessageTextEdit.clear
        reload
      end

      def reload()
        enableCommit
      end

      attr_accessor :repository
      def setRepository(repo)
        # TODO: disconnect old repo
        #self.disconnect(@repository.qt)

        @repository = repo

        connect(@repository.qt, SIGNAL('stageChanged()'), self, SLOT('enableCommit()'))

        reload
      end

      protected

      def enableCommit()
        if repository.status.staged.empty?
          @ui.commitErrorLabel.text = "No files staged"
          @ui.commitButton.enabled = false
        elsif @ui.commitMessageTextEdit.to_plain_text.empty?
          @ui.commitErrorLabel.text = "No commit message"
          @ui.commitButton.enabled = false
        else
          @ui.commitErrorLabel.text = ""
          @ui.commitButton.enabled = true
        end
      end
    end
  end
end