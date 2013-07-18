VALAC=valac-0.20
VALAFLAGS:=--target-glib=2.36 --save-temps $(VALAFLAGS)

all: fido fido-window

fido: fido.vala ../server/dbus-interface.vala
	valac --pkg gio-2.0 $^ -o $@ $(VALAFLAGS)

fido-window: fido-window.vala
	valac --vapidir=. --pkg gtk+-3.0 --pkg webkitgtk-3.0 --thread $^ -o $@ $(VALAFLAGS)
	
clean:
	-rm fido fido-window *.c

