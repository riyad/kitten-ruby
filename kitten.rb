#!/usr/bin/env ruby

require 'korundum4'

module Kitten
  class MainWindow < KDE::MainWindow
      def initialize(*args)
        super
      end
  end
end

description = "A GUI for Git."
version     = "0.1"
aboutData   = KDE::AboutData.new("kitten", "", KDE.ki18n("Kitten"),
    version, KDE.ki18n(description),
    KDE::AboutData::License_GPL, KDE.ki18n("(C) 2009 Riyad Preukschas"))

aboutData.addAuthor(KDE.ki18n("Riyad Preukschas"), KDE.ki18n("Author"), "riyad@informatik.uni-bremen.de")

KDE::CmdLineArgs.init(ARGV, aboutData)

app = KDE::Application.new()

kitten = Kitten::MainWindow.new()
kitten.show()

app.exec()
