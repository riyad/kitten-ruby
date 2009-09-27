#!/usr/bin/env ruby
# Copyright (C) 2009  Riyad Preukschas <riyad@informatik.uni-bremen.de>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
    KDE::AboutData::License_GPL_V3, KDE.ki18n("(C) 2009 Riyad Preukschas"))

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
