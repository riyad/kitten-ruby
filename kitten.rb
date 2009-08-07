#!/usr/bin/env ruby

require 'core_ext/kernel'

require 'kitten/main_window'

description = "A GUI for Git."
version     = "0.1"
about_data   = KDE::AboutData.new("kitten", "", KDE.ki18n("Kitten"),
    version, KDE.ki18n(description),
    KDE::AboutData::License_GPL, KDE.ki18n("(C) 2009 Riyad Preukschas"))

# TODO: add_author seems not to work
about_data.addAuthor(KDE.ki18n("Riyad Preukschas"), KDE.ki18n("Author"), "riyad@informatik.uni-bremen.de")

KDE::CmdLineArgs.init(ARGV, about_data)

app = KDE::Application.new

kitten = Kitten::MainWindow.new
kitten.show

app.exec
