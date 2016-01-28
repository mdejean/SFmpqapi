STATICLIB = SFmpq_static.lib
SHAREDLIB = SFmpq.dll
SHAREDDEF = SFmpq.def
IMPLIB    = SFmpq.lib
INCLUDEINSTALL = SFmpqapi.h

#
# Set to 1 if shared object needs to be installed
#
SHARED_MODE=0

DEBUG = 1

#LOC = -DASMV
LOC =

ifdef DEBUG
LOC += -DDEBUG -g -Wall \
  -Wno-missing-braces -Wextra -Wno-missing-field-initializers -Wformat=2 \
  -Wswitch-default -Wswitch-enum -Wcast-align -Wpointer-arith -Winline \
  -Wstrict-overflow=5 -Wundef -Wcast-qual -Wshadow -Wunreachable-code \
  -Wlogical-op -Wfloat-equal -Wstrict-aliasing=2 -Wredundant-decls
#C: -Wold-style-definition -Wnested-externs -Wstrict-prototypes -Wbad-function-cast
endif

PREFIX =
CC = $(PREFIX)g++
CFLAGS = $(LOC) -m32 -std=c++11 -DSFMPQ_STATIC -DSFMPQAPI_EXPORTS -D_USRDLL

AS = $(CC)
ASFLAGS = $(LOC) -Wall

#fixme: shouldn't need to reference again?
LIBS= -lSComp_static -lbz2 -lz
LD = $(CC)
LDFLAGS = $(LOC) -mdll -static -L../SComp -L../SComp/bzip2 -L../SComp/zlib

AR = $(PREFIX)ar
ARFLAGS = rcs

RC = $(PREFIX)windres
RCFLAGS = --define GCC_WINDRES

STRIP = $(PREFIX)strip

CP = cp -fp
# If GNU install is available, replace $(CP) with install.
INSTALL = $(CP)
RM = rm -f

prefix ?= /usr/local
exec_prefix = $(prefix)

#export definitions requested
DEF = SFmpqapi.def
OBJS = SFmpqapi.o MpqBlockTable.o MpqHashTable.o MpqCrypt.o SFUtil.o resource.o
#objects for the static library
OBJA = SFmpq_static.o

all: $(STATICLIB) $(SHAREDLIB) $(IMPLIB)

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

.cpp.o:
	$(CC) $(CFLAGS) -c -o $@ $<

resource.o:
	$(RC) $(RCFLAGS) SFmpqapi.rc $@

$(STATICLIB): $(OBJS) $(OBJA)
#make sure CU with static is referenced
	ld -i $(OBJA) $(firstword $(OBJS)) -o _static_cu.o
	$(AR) $(ARFLAGS) $@ _static_cu.o $(wordlist 2, 9999, $(OBJS))

$(IMPLIB): $(SHAREDLIB)

$(SHAREDDEF): $(SHAREDLIB)

$(SHAREDLIB): $(OBJS) $(DEF)
	$(CC) -mdll -Wl,--out-implib,$(IMPLIB) -Wl,--output-def,$(SHAREDDEF) $(LDFLAGS) \
	-o $@ $(DEF) $(OBJS) $(LIBS)
ifndef DEBUG
	$(STRIP) $@
endif

.PHONY: clean

clean:
	-$(RM) $(STATICLIB)
	-$(RM) $(SHAREDLIB)
	-$(RM) $(SHAREDDEF)
	-$(RM) $(IMPLIB)
	-$(RM) *.o
	-$(RM) *.exe

