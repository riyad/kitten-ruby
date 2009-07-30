#!/usr/bin/env ruby

require 'Korundum'

module Kitten
  class MainWindow < KDE::MainWindow
      def initialize(*args)
        super
      end
  end
end

description = "A GUI for Git."
version     = "0.1"
aboutData   = KDE::AboutData.new("Kitten", "",
    version, description, KDE::AboutData::License_GPL_V3,
    "(C) 2009 Riyad Preukschas")

aboutData.addAuthor("Riyad Preukschas", "Author", "riyad@informatik.uni-bremen.de")

KDE::CmdLineArgs.init(ARGV, aboutData)

app = KDE::Application.new()

kitten = Kitten::MainWindow.new()
kitten.show()

app.exec()
