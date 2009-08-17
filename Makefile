
QRC_DIR = .
QRC = icons
QRC_FILES = ${QRC:%=${QRC_DIR}/%.qrc}
QRC_GENERATED_FILES = ${QRC:%=${QRC_DIR}/qrc_%.rb}

UI_DIR = ./kitten/ui
UI = commit_widget main_window repositories_dialog
UI_FILES = ${UI:%=${UI_DIR}/%.ui}
UI_GENERATED_FILES = ${UI:%=${UI_DIR}/ui_%.rb}

all: ${QRC_FILES} ${QRC_GENERATED_FILES} ${UI_FILES} ${UI_GENERATED_FILES}

kitten/ui/ui_%.rb: kitten/ui/%.ui
	rbuic4 -kde $< -o $@

qrc_%.rb: %.qrc
	rbrcc icons.qrc -o qrc_icons.rb
