# stone		simple repeater
# Copyright(c)1995-2004 by Hiroaki Sengoku <sengoku@gcd.org>
#
# -DUSE_POP	use POP -> APOP conversion
# -DUSE_SSL	use OpenSSL
# -DCPP		preprocessor for reading config. file
# -DIGN_SIGTERM	ignore SIGTERM signal
# -DUNIX_DAEMON	fork into background and become a UNIX Daemon
# -DNO_BCOPY	without bcopy(3)
# -DNO_SNPRINTF	without snprintf(3)
# -DNO_SYSLOG	without syslog(2)
# -DNO_RINDEX	without rindex(3)
# -DNO_THREAD	without thread
# -DNO_PID_T	without pid_t
# -DNO_ADDRINFO without getaddrinfo
# -DPTHREAD     use Posix Thread
# -DPRCTL	use prctl(2) - operations on a process

CFLAGS=		# -g

SSL=		/usr/local/ssl
SSL_FLAGS=	-DUSE_SSL
SSL_LIBS=	-lssl -lcrypto

POP_FLAGS=	-DUSE_POP
POP_LIBS=	md5c.o

MINGWCC=	mingw32-gcc
MC=		wmc
RC=		wrc
WINDRES=	windres
SVC_LIBS=	logmsg.o

all:
	@echo "run make with one of the following arguments"
	@echo "linux     ; for Linux"
	@echo "zaurus    ; for Linux Zaurus"
	@echo "fon       ; for La Fonera"
	@echo "bsd       ; for FreeBSD or BSD/OS"
	@echo "macosx    ; for Mac OS X"
	@echo "sun       ; for SunOS 4.x with gcc"
	@echo "solaris   ; for Solaris with gcc"
	@echo "hp        ; for HP-UX with gcc"
	@echo "irix      ; for IRIX"
	@echo "emx       ; for OS/2 with EMX"
	@echo "using POP -> APOP conv., add '-pop' (example: linux-pop)"
	@echo "using above conv. and OpenSSL, add '-ssl' (example: linux-ssl)"

clean:
	rm -f stone $(POP_LIBS) stone.obj md5c.obj stone.o $(SVC_LIBS) MSG00001.bin logmsg.h logmsg.rc cryptoapi.o

md5c.c:
	@echo "*** md5c.c is contained in RFC1321"

stone: stone.c
	$(CC) $(CFLAGS) $(FLAGS) -o $@ $? $(LIBS)

pop_stone: $(POP_LIBS)
	$(MAKE) FLAGS="$(POP_FLAGS)" LIBS="$(POP_LIBS)" $(TARGET)

ssl_stone:
	$(MAKE) FLAGS="$(POP_FLAGS) $(SSL_FLAGS) $(FLAGS)" LIBS="$(LIBS) $(SSL_LIBS)" $(TARGET)

logmsg.rc: logmsg.mc
	$(MC) -i $?

logmsg.res: logmsg.rc
	$(RC) $?

logmsg.o: logmsg.res
	$(WINDRES) $? -o $@

cryptoapi.o: cryptoapi.c
	$(MINGWCC) -c $? -o $@

linux:
	$(MAKE) FLAGS="-O -Wall -DCPP='\"/usr/bin/cpp -traditional\"' -DPTHREAD -DUNIX_DAEMON -DPRCTL -DSO_ORIGINAL_DST=80 -DUSE_EPOLL -D_GNU_SOURCE $(FLAGS)" LIBS="-lpthread $(LIBS)" stone

linux-pop:
	$(MAKE) TARGET=linux pop_stone

linux-ssl:
	$(MAKE) TARGET=linux ssl_stone LIBS="-ldl"

zaurus:
	$(MAKE) CC="arm-linux-gcc" FLAGS="-O -Wall -DPTHREAD -DUNIX_DAEMON $(FLAGS)" LIBS="-lpthread $(LIBS)" stone
	arm-linux-strip stone

zaurus-pop:
	$(MAKE) CC="arm-linux-gcc" TARGET=zaurus pop_stone

zaurus-ssl:
	$(MAKE) CC="arm-linux-gcc" SSL_LIBS="-lssl -lcrypto" TARGET=zaurus ssl_stone

fon:
	$(MAKE) CC="mips-linux-uclibc-gcc" FLAGS="-O -Wall -DPTHREAD -DUNIX_DAEMON -DPRCTL $(FLAGS)" LIBS="-lpthread $(LIBS)" stone
	mips-linux-uclibc-strip stone

fon-pop:
	$(MAKE) CC="mips-linux-uclibc-gcc" TARGET=fon pop_stone

fon-ssl:
	$(MAKE) CC="mips-linux-uclibc-gcc" SSL_LIBS="-lssl -lcrypto" TARGET=fon ssl_stone

bsd:
	$(MAKE) FLAGS="-DCPP='\"/usr/bin/cpp -traditional\"' -D_THREAD_SAFE -DPTHREAD -DREG_NOERROR=0 $(FLAGS)" LIBS="-pthread $(LIBS)" stone

bsd-pop:
	$(MAKE) TARGET=bsd pop_stone

bsd-ssl:
	$(MAKE) TARGET=bsd ssl_stone

macosx:
	$(MAKE) FLAGS="-DCPP='\"/usr/bin/cpp -traditional\"' -D_THREAD_SAFE -DPTHREAD $(FLAGS)" stone

macosx-pop:
	$(MAKE) TARGET=macosx pop_stone

macosx-ssl:
	$(MAKE) TARGET=macosx SSL=/usr ssl_stone

sun:
	$(MAKE) CC=gcc FLAGS="-DNO_ADDRINFO -DNO_SNPRINTF -DIGN_SIGTERM -DCPP='\"/usr/lib/cpp\"' $(FLAGS)" stone

sun-pop:
	$(MAKE) TARGET=sun pop_stone

sun-ssl:
	$(MAKE) TARGET=sun ssl_stone

solaris:
	$(MAKE) CC=gcc FLAGS="-DPTHREAD -D_REENTRANT $(FLAGS)" LIBS="-lnsl -lsocket -lpthread -lthread $(LIBS)" stone

solaris-pop:
	$(MAKE) TARGET=solaris pop_stone

solaris-ssl:
	$(MAKE) TARGET=solaris ssl_stone

hp:
	$(MAKE) CC=gcc FLAGS="-DNO_SNPRINTF -DH_ERRNO -DCPP='\"/lib/cpp\"' $(FLAGS)" stone

hp-pop:
	$(MAKE) TARGET=hp pop_stone

hp-ssl:
	$(MAKE) TARGET=hp ssl_stone

irix:
	$(MAKE) FLAGS="-DNO_SNPRINTF $(FLAGS)" stone

irix-pop:
	$(MAKE) TARGET=irix pop_stone

irix-ssl:
	$(MAKE) TARGET=irix ssl_stone

emx-pop:
	$(MAKE) TARGET=emx pop_stone

emx-ssl:
	$(MAKE) TARGET=emx ssl_stone
