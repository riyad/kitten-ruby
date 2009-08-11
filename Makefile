
all: *.rb kitten/*.rb

kitten/ui_main_window.rb: kitten/main_window.ui
	rbuic4 -kde kitten/main_window.ui -o kitten/ui_main_window.rb

kitten/ui_repositories_dialog.rb: kitten/repositories_dialog.ui
	rbuic4 -kde kitten/repositories_dialog.ui -o kitten/ui_repositories_dialog.rb

qrc_icons.rb: icons.qrc
	rbrcc -name icons icons.qrc -o qrc_icons.rb
