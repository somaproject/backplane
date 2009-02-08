VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/bitcnt/behavioral.dat: $(WORKDIR)/touched ../../vhdl/bitcnt.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/bitcnt.vhd

hw: $(WORKDIR)/bitcnt/behavioral.dat 

comp: 

$(WORKDIR)/bitcnttest/behavioral.dat: $(WORKDIR)/touched bitcnttest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) bitcnttest.vhd

sim: $(WORKDIR)/bitcnttest/behavioral.dat 
runsim: all
	$(VHDLS) bitcnttest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
