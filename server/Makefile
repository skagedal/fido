all: fido-server fido-db

fido-server: fido-server.vala fido-dbus-interface.vala
	valac --pkg gio-2.0 $^ -o $@

fido-db: fido-db.vala 
	valac --pkg gio-2.0 --pkg sqlheavy-0.1 $^ 

