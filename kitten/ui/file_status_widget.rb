
require File.join(File.dirname(__FILE__), 'ui_file_status_widget')

require 'cgi'

module Kitten
  module Ui
    class FileStatusWidget < Qt::Widget
      slots 'clear()'

      def clear()
        @ui.typeLabel.text = ""
        @ui.contentBrowser.text = ""
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
        data.gsub!(/^(diff|index|(\+|-){3}).*\n/, '')
        data.gsub!(/^(\+.*)/, '<span class="add">\\1</span>')
        data.gsub!(/^(-.*)/, '<span class="remove">\\1</span>')
        data.gsub!(/^(@@.*)/, '<span class="info">\\1</span>')
        data.gsub!(/\n/, "<br/>")
        data
      end

      def showFileStatus()
        data = if binary?
                  '<span class="warning">Binary file (content not shown)</span>'
                else
                  format(data())
                end

        @ui.typeLabel.text = mimeType.name
        data = <<-END
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">
<html>
<head>
  <meta name="qrichtext" content="1" />
  <style type="text/css">
    body {
      font-family: 'Droid Sans Mono';
      font-size: 10pt;
      font-weight: 400;
      font-style: normal;
      white-space: normal;
    }
    .add { color: green; }
    .info { color: blue; }
    .remove { color: red; }
    .warning { color: yellow; }
  </style>
</head>
<body>
#{data}
</body>
</html>
        END
        @ui.contentBrowser.html = data
      end
    end
  end
end