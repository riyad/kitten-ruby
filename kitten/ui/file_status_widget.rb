
require File.join(File.dirname(__FILE__), 'diff_widget')
require File.join(File.dirname(__FILE__), 'ui_file_status_widget')

class Ui_FileStatusWidget
  DiffWidget = Kitten::Ui::DiffWidget
end

module Kitten
  module Ui
    class FileStatusWidget < Qt::Widget
      slots 'clear()'

      def clear()
        empty_pixmap = Qt::Pixmap.new
        @ui.stageIconLabel.pixmap = empty_pixmap
        @ui.stageLabel.text = ''
        @ui.statusIconLabel.pixmap = empty_pixmap
        @ui.statusLabel.text = ''
        @ui.mimeTypeIconLabel.pixmap = empty_pixmap
        @ui.filePathLabel.text = ''
        @ui.fileInfoLabel.text = ''
        @ui.diffWidget.diff = ''
        @byte_array = nil
      end

      def initialize(*args)
        super {}

        @ui = Ui_FileStatusWidget.new
        @ui.setupUi(self)

        yield(self) if block_given?
      end

      def reload()
        clear
      end

      attr_accessor :file_status
      def setFileStatus(file_status)
        @file_status = file_status
        clear
        showFileStatus
      end

      attr_accessor :repository
      def setRepository(repo)
        # TODO: disconnect old repo
        #self.disconnect(@repository.qt)

        @repository = repo

        connect(@repository.qt, SIGNAL('logChanged()'), self, SLOT('clear()'))

        reload
      end

      protected

      def isBinary()
        KDE::MimeType.isBufferBinaryData(byteArray)
      end

      def byteArray()
        @byte_array ||= Qt::ByteArray.new(data(:blob))
      end

      def data(type = type())
        if type == :blob
          if file_status.blob.respond_to? :data
            file_status.blob.data
          else
            file_status.blob
          end
        else
          file_status.diff.diff
        end
      end

      def mimeType()
        KDE::MimeType.find_by_name_and_content(file_status.path, byteArray)
      end

      # returns :blob or :diff
      def type()
        if file_status.untracked?
          :blob
        else
          :diff
        end
      end

      def showFileStatus()
        if file_status.changes_staged?
          stage = 'Staged'
          stageIcon = Qt::Icon.new(':/icons/16x16/status/git-file-staged')
        else
          stage = 'Unstaged'
          stageIcon = Qt::Icon.new(':/icons/16x16/status/git-file-unstaged')
        end
        unless binary?
          if file_status.untracked?
            file_info = "#{file_status.blob.lines.to_a.size} lines"
          else
            file_info = %Q{<html><body><span style="color: green;">+#{file_status.diff.insertions}</span> <span style="color: red;">-#{file_status.diff.deletions}</span> lines</body></html>}
          end
        else
          file_info = "#{byte_array.size} Bytes"
        end

        status = file_status.status.id2name
        @ui.stageIconLabel.pixmap = stageIcon.pixmap(16)
        @ui.stageLabel.text = stage
        @ui.statusIconLabel.pixmap = Qt::Icon.new(":/icons/16x16/status/git-file-#{status}").pixmap(16)
        @ui.statusLabel.text = status.gsub(/(.)(.*)/) { "#{$1.upcase}#{$2}" }
        @ui.mimeTypeIconLabel.pixmap = KDE::Icon.new(mime_type.icon_name).pixmap(32)
        @ui.filePathLabel.text = file_status.path
        @ui.fileInfoLabel.text = file_info
        @ui.diffWidget.diff = binary? ? 'Binary file (content not shown)' : data
      end
    end
  end
end