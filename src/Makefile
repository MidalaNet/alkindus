# Makefile

PROGRAM = alkindus
SRC = main.vala
PKGS = --pkg gtk+-3.0 --pkg gmodule-2.0 --pkg poppler-glib
VALAC = valac
VALACOPTS = -g --save-temps
BUILD_ROOT = .
PREFIX = /usr/local
BINDIR = $(PREFIX)/bin
DATADIR = $(PREFIX)/share/$(PROGRAM)

all:
	@$(VALAC) $(VALACOPTS) $(SRC) -o $(PROGRAM) $(PKGS)

release: clean
	@$(VALAC) -X -O2 $(SRC) -o $(PROGRAM) $(PKGS)

install: all
	@install -m 0755 $(PROGRAM) $(BINDIR)
	@install -d $(DATADIR)
	@install -m 0644 $(BUILD_ROOT)/main.ui $(DATADIR)

clean:
	@rm -v -fr *~ *.c $(PROGRAM)
