all: fido fido-window

fido: fido.vala
	valac --pkg gio-2.0 $^ -o $@

fido-window: fido-window.vala
	valac --pkg gtk+-2.0 --pkg webkit-1.0 --thread $^ -o $@
