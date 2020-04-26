ifndef HDF5_HOME
 $(error HDF5_HOME must be set to the location of your cloned and installed hdf5-group repository)
endif

W_OPTS         = -Wall -Wno-strict-aliasing -Wno-parentheses -Wextra -Werror -Wsign-compare
I_OPTS         = -I${HDF5_HOME}/include -Isrc
L_OPTS         = -L${HDF5_HOME}/lib -lhdf5 -lz -lpthread -lssl -shared
OPTS           = -DKXVER=3 -fPIC

MS             = $(shell getconf LONG_BIT)
TGT            = hdf5.so

ifeq ($(shell uname),Linux)
 LNK     = -lrt
 OSFLAG  = l
 OSXOPTS =
else ifeq ($(shell uname),Darwin)
 LNK     =
 OSFLAG  = m
 OSXOPTS = -undefined dynamic_lookup  -mmacosx-version-min=10.12
endif

QARCH = $(OSFLAG)$(MS)
Q     = $(QHOME)/$(QARCH)

all: src/util.o
	$(CC) src/util.o $(L_OPTS) $(LNK) -o hdf5.so

src/util.o: src/util.c src/k.h
	$(CC) src/util.c -m$(MS) $(OPTS) $(I_OPTS) $(W_OPTS) -c -o src/util.o

src/hdf5_utils.o: src/hdf5_utils.c src/k.h
	$(CC) src/hdf5_utils.c -m$(MS) $(OPTS) $(I_OPTS) $(W_OPTS) -c -o src/hdf5_utils.o

src/k.h:
	curl -s -L https://github.com/KxSystems/kdb/raw/master/c/c/k.h -o src/k.h

install:
	mkdir -p $(QARCH)
	install  $(TGT) $(Q)
	install  $(TGT) $(QARCH)

clean:
	rm -f src/*.o hdf5.so $(QARCH)/hdf5.so
