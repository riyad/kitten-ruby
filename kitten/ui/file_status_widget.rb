
require File.join(File.dirname(__FILE__), 'ui_file_status_widget')

require 'cgi'

module Kitten
  module Ui
    class FileStatusWidget < Qt::Widget
      slots 'clear()'

      def clear()
        @ui.stageIconLabel.pixmap = ''
        @ui.stageLabel.text = ''
        @ui.statusIconLabel.text = ''
        @ui.statusLabel.text = ''
        @ui.mimeTypeIconLabel.text = ''
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
        showFileStatus if file_status
      end

      attr_accessor :file_status
      def setFileStatus(file_status)
        @file_status = file_status
        reload
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
        @byte_array ||= Qt::ByteArray.new(data)
      end

      def data()
        if type == :blob
          file_status.blob.to_s
        else
          file_status.diff.to_s
        end
      end

      def mimeType()
        if type == :blob
          KDE::MimeType.find_by_name_and_content(file_status.path, byteArray)
        else
          KDE::MimeType.find_by_content(byteArray)
        end
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
        data.gsub!(/^((diff|index|\+\+\+|---).*\n)/, '')
        data.gsub!(/^(\+.*)/, '<span class="add">\\1</span>')
        data.gsub!(/^(-.*)/, '<span class="remove">\\1</span>')
        data.gsub!(/^(@@.*)/, '<span class="info">\\1</span>')
        data
      end

      def showFileStatus()
        data = if binary?
                  '<span class="warning">Binary file (content not shown)</span>'
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
    .warning { color: yellow; }
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
        else
          stage = 'Unstaged'
          stageIcon = Qt::Icon.new(':/icons/16x16/status/git-file-unstaged')
        end
        status = file_status.state.id2name
        @ui.stageIconLabel.pixmap = stageIcon.pixmap(16)
        @ui.stageLabel.text = stage
        @ui.statusIconLabel.pixmap = Qt::Icon.new(":/icons/16x16/status/git-file-#{status}").pixmap(16)
        @ui.statusLabel.text = status.gsub(/(.)(.*)/) { "#{$1.upcase}#{$2}" }
        @ui.mimeTypeIconLabel.pixmap = KDE::Icon.new(mime_type.icon_name).pixmap(32)
        @ui.filePathLabel.text = file_status.path
        @ui.fileInfoLabel.text = "#{file_status.blob.to_s.size} Bytes"
        @ui.contentView.html = data
      end
    end
  end
end