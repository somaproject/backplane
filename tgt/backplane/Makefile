
CXXFLAGS =  `pkg-config --cflags somanetwork-1.0`
LDFLAGS = `pkg-config --libs somanetwork-1.0 sigc++-2.0` -lboost_program_options-gcc41-mt  -lboost_thread-gcc41-mt 

all: dspboot

dspboot.o: dspboot.cc

dspboot : dspboot.o

test.o: test.cc
test: test.o
