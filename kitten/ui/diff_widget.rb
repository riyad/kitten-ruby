
require 'cgi'

module Kitten
  module Ui
    class DiffWidget < KDE::TextBrowser
      def diff=(diff_text)
        self.html = format(diff_text)
      end

      private

      def format(unformatted_diff)
        formatted_diff = CGI.escapeHTML(unformatted_diff)
        formatted_diff.gsub!(/^(diff --git .*)/,    '<span class="header">\\1</span>')
        formatted_diff.gsub!(/^(index .*)/,         '<span class="header info">\\1</span>')
        formatted_diff.gsub!(/^(new file .*)/,      '<span class="header add">\\1</span>')
        formatted_diff.gsub!(/^(deleted file .*)/,  '<span class="header remove">\\1</span>')
        formatted_diff.gsub!(/^(\+\+\+ .*)/,        '<span class="header add">\\1</span>')
        formatted_diff.gsub!(/^(--- .*)/,           '<span class="header remove">\\1</span>')
        formatted_diff.gsub!(/^(\+.*)/,             '<span class="add">\\1</span>')
        formatted_diff.gsub!(/^(-.*)/,              '<span class="remove">\\1</span>')
        formatted_diff.gsub!(/^(@@.*)/,             '<span class="info">\\1</span>')
        formatted_diff.gsub!(/^(\\.*)/,             '<span class="warning">\\1</span>')
        formatted_diff
        formatted_diff = <<-END
<?xml version="1.0" ?>
<html>
<head>
  <style type="text/css">
    pre {
      font-family: 'Droid Sans Mono';
    }
    div { display: inline; }
    .add { color: #008C00; }
    .header { background-color: #EEEEEE; }
    .info { color: #0057AE; }
    .remove { color: #BF0303; }
    .warning { color: #FFAA00; }
  </style>
</head>
<body>
<pre>#{formatted_diff}</pre>
</body>
</html>
        END
        formatted_diff
      end
    end
  end
end
