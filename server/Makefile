LIBS=--pkg gobject-2.0 --pkg gio-2.0 --pkg libsoup-2.4 --pkg libxml2-2.0 --pkg sqlheavy-0.1 --pkg libgrss-0.5 --vapidir=../vapi

all: fido-server fido-db

fido-server: fido-server.vala fido-dbus-interface.vala
	valac --pkg gio-2.0 $^ -o $@

fido-db: fido-db.vala
	valac $(LIBS) $^ 

