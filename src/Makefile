# Makefile
 
PROGRAM = alkindus
SRC = main.vala
PKGS = --pkg gtk+-2.0 --pkg gmodule-2.0 --pkg poppler-glib 
VALAC = valac
VALACOPTS = -g --save-temps
BUILD_ROOT = 1

all:
	@$(VALAC) $(VALACOPTS) $(SRC) -o $(PROGRAM) $(PKGS)

release: clean
	@$(VALAC) -X -O2 $(SRC) -o main_release $(PKGS)

clean:
	@rm -v -fr *~ *.c $(PROGRAM)