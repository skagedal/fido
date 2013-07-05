all: fido fido-window

fido: fido.vala
	valac --pkg gio-2.0 $^ -o $@

fido-window: fido-window.vala
	valac --vapidir=. --pkg gtk+-3.0 --pkg webkitgtk-3.0 --thread $^ -o $@

