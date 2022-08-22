CC = gcc
CFLAGS = -Wall -Werror -c -lpthread -DPAILLIER_THREAD -fpic
DEPS = include/paillier.h src/tools.h
OBJ_LIB = build/tools.o build/paillier.o build/paillier_manage_keys.o build/paillier_io.o
OBJ_INTERPRETER = build/main.o 

ifeq ($(PREFIX), )
	PREFIX := /
endif

#standaloine command interpreter executable recipe	
build/paillier_standalone: build/main.o $(OBJ_LIB)
	$(CC) -Wall -o $@ $^ -lgmp

#command interpreter executable recipe	
build/paillier: build/main.o lib/libpaillier.so
	$(CC) -Wall -o $@ $< -Llib -l:libpaillier.so -lgmp -lpthread

#shared library recipe	
lib/libpaillier.so: $(OBJ_LIB)
	mkdir -p lib
	$(CC) -shared -o $@ $^ -lpthread

# static library
lib/libpaillier.a: $(OBJ_LIB)
	mkdir -p lib
	ar rcs lib/libpaillier.a $(OBJ_LIB)

#release recipes
build/%.o: src/%.c $(DEPS)
	mkdir -p $(@D)
	$(CC) -o  $@ $< $(CFLAGS)

#documentation recipe
.PHONY: doc
doc:
	mkdir -p doc
	# doxygen

install: all
	install -d $(PREFIX)/lib/
	install -m 644 lib/libpaillier.a $(PREFIX)/lib/
	install -m 644 lib/libpaillier.so $(PREFIX)/lib/
	install -d $(PREFIX)/include/
	install -m 644 include/paillier.h $(PREFIX)/include/
	install -d $(PREFIX)/bin/
	install -m 755 build/paillier $(PREFIX)/bin

#clean project
.PHONY: clean
clean:
	rm -fr build/* doc/* lib/* test/*.txt

debug: build/paillier
debug: CFLAGS += -ggdb -DPAILLIER_DEBUG
release: build/paillier
standalone: build/paillier_standalone
sharedlib: lib/libpaillier.so
staticlib: lib/libpaillier.a
all: release doc staticlib sharedlib
