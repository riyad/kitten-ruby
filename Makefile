
QRC_DIR = ./kitten/resources
QRC = icons
QRC_FILES = ${QRC:%=${QRC_DIR}/%.qrc}
QRC_GENERATED_FILES = ${QRC:%=${QRC_DIR}/qrc_%.rb}

UI_DIR = ./kitten/ui
UI = commit_widget commit_info_widget file_status_widget history_widget main_window repositories_dialog stage_widget
UI_FILES = ${UI:%=${UI_DIR}/%.ui}
UI_GENERATED_FILES = ${UI:%=${UI_DIR}/ui_%.rb}

all: ${QRC_FILES} ${QRC_GENERATED_FILES} ${UI_FILES} ${UI_GENERATED_FILES}

kitten/ui/ui_%.rb: kitten/ui/%.ui
	rbuic4 -kde $< -o $@

kitten/resources/qrc_%.rb: kitten/resources/%.qrc
	rbrcc $< -o $@
