
require File.join(File.dirname(__FILE__), 'ui_file_status_widget')

require 'cgi'

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
        @ui.contentView.html = ''
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
          if file_status.blob.respond_to? :contents
            file_status.blob.contents
          else
            file_status.blob
          end
        else
          file_status.diff.patch
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

      def format(data)
        data = CGI.escapeHTML(data)
        data.gsub!(/^((diff|index|new|\+\+\+|---).*\n)/, '')
        data.gsub!(/^(\+.*)/, '<span class="add">\\1</span>')
        data.gsub!(/^(-.*)/, '<span class="remove">\\1</span>')
        data.gsub!(/^(@@.*)/, '<span class="info">\\1</span>')
        data.gsub!(/^(\\.*)/, '<span class="warning">\\1</span>')
        data
      end

      def showFileStatus()
        data = if binary?
                  'Binary file (content not shown)'
                else
                  format(data())
                end
        data = <<-END
<?xml version="1.0" ?>
<html>
<head>
  <style type="text/css">
    pre {
      font-family: 'Droid Sans Mono';
    }
    .add { color: green; }
    .info { color: blue; }
    .remove { color: red; }
    .warning { color: grey; }
  </style>
</head>
<body>
<pre>#{data}</pre>
</body>
</html>
        END
        if file_status.staged?
          stage = 'Staged'
          stageIcon = Qt::Icon.new(':/icons/16x16/status/git-file-staged')
          blob = file_status.blob(:index).contents
        else
          stage = 'Unstaged'
          stageIcon = Qt::Icon.new(':/icons/16x16/status/git-file-unstaged')
          blob = file_status.blob(:file)
        end
        status = file_status.state.id2name
        @ui.stageIconLabel.pixmap = stageIcon.pixmap(16)
        @ui.stageLabel.text = stage
        @ui.statusIconLabel.pixmap = Qt::Icon.new(":/icons/16x16/status/git-file-#{status}").pixmap(16)
        @ui.statusLabel.text = status.gsub(/(.)(.*)/) { "#{$1.upcase}#{$2}" }
        @ui.mimeTypeIconLabel.pixmap = KDE::Icon.new(mime_type.icon_name).pixmap(32)
        @ui.filePathLabel.text = file_status.path
        @ui.fileInfoLabel.text = "#{blob.size} Bytes"
        @ui.contentView.html = data
      end
    end
  end
end