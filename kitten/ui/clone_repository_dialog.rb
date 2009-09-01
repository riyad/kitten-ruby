
require File.join(File.dirname(__FILE__), 'ui_clone_repository_dialog')

module Kitten
  module Ui
    class CloneRepositoryDialog < Qt::Dialog
      slots 'on_cloneUrlRequester_textChanged(const QString&)',
            'on_cloneButton_clicked()',
            'on_localUrlRequester_textChanged(const QString&)',
            'on_stackedWidget_currentChanged(int)'

      def initialize(*args)
        super

        @ui = Ui_CloneRepositoryDialog.new
        @ui.setup_ui(self)

        enable_clone
      end

      def on_cloneUrlRequester_textChanged(text)
        enable_clone
      end

      def on_cloneButton_clicked()
        enable_finish
        @ui.stackedWidget.current_index = 1
      end

      def on_localUrlRequester_textChanged(text)
        enable_clone
      end

      def on_stackedWidget_currentChanged(index)
        case index
        when 0
          enable_clone
          enable_finish
        when 1
          # update the view
          repaint
          KDE::Application.process_events

          # do the actual cloning
          clone

          # show that the cloning has finished
          @finished = true
          enable_finish
        end
      end

      def repositoryPath()
        @ui.localUrlRequester.text
      end

      protected

      def clone()
        repository = @ui.cloneUrlRequester.url.url
        path = @ui.localUrlRequester.url.path_or_url(KDE::Url::RemoveTrailingSlash)
        FileUtils.rm_r(path)

        # extracts the repo name from the path
        name = path.slice!(%r{#{File::Separator}[^#{File::Separator}]+$})
        name = name[1..-1] if name.start_with?(File::Separator)

        # TODO: display cloning progress
        Git.clone(repository, name, :path => path)
      end

      def enableClone()
        clone_url = @ui.cloneUrlRequester.url
        local_url = @ui.localUrlRequester.url
        case
        when clone_url.empty?
          error_message = 'No clone source.'
          enabled = false
        when !clone_url.valid?
          error_message = 'Clone source has an invalid URL.'
          enabled = false
        when local_url.empty?
          error_message = 'No clone destination.'
          enabled = false
        when !local_url.valid?
          error_message = 'Clone destination has an invalid URL.'
          enabled = false
        when !File.exist?(local_url.path_or_url)
          error_message = 'Clone destination does not exist.'
          enabled = false
        when Dir.entries(local_url.path_or_url) != %w{. ..}
          error_message = 'Clone destination is not empty.'
          enabled = false
        else
          error_message = nil
          enabled = true
        end
        @ui.errorLabel.text = error_message
        @ui.cloneButton.enabled =  enabled
      end

      def enableFinish()
        @ui.cloningFinishedIconLabel.visible = @finished
        @ui.cloningFinishedLabel.visible = @finished
        @ui.finishedButton.enabled = @finished
      end
    end
  end
end
