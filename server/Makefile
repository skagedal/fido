VALAC=valac-0.20
# use --Xcc=-w to disable C warnings
VALAFLAGS=--target-glib=2.36 --save-temps --Xcc=-w
LIBS=--pkg gobject-2.0 --pkg gio-2.0 --pkg libsoup-2.4 --pkg libxml2-2.0 --pkg sqlheavy-0.1 --pkg libgrss-0.5 --vapidir=../vapi

all: fido-server 

fido-server: fido-server.vala dbus-interface.vala database.vala
	$(VALAC) $(LIBS) $^ -o $@ $(VALAFLAGS)

clean:
	-rm fido-server *.c

