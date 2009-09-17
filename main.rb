#!/usr/bin/env ruby

require 'core_ext/kernel'
require 'core_ext/module'

require 'rubygems'
require 'lib/grit'
require 'grit_ext'

require 'korundum4'

require 'kitten/resources/qrc_icons.rb'

require 'kitten/ui/main_window'
require 'kitten/ui/repositories_dialog'

description = "A GUI for Git."
version     = "0.1"
about_data   = KDE::AboutData.new("kitten", "", KDE.ki18n("Kitten"),
    version, KDE.ki18n(description),
    KDE::AboutData::License_GPL, KDE.ki18n("(C) 2009 Riyad Preukschas"))

# TODO: add_author seems not to work
about_data.addAuthor(KDE.ki18n("Riyad Preukschas"), KDE.ki18n("Author"), "riyad@informatik.uni-bremen.de")

KDE::CmdLineArgs.init(ARGV, about_data)

KDE::Application.new

repos_dialog = Kitten::Ui::RepositoriesDialog.new
repos_dialog.exec

if repos_dialog.result == Qt::Dialog::Accepted
  Kitten::Ui::MainWindow.new do |kitten|
    kitten.repository = repos_dialog.selected_repository_path
    kitten.show
  end

  $kapp.exec
end
