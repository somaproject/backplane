VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/ipchecksum/behavioral.dat: $(WORKDIR)/touched ../../vhdl/ipchecksum.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/ipchecksum.vhd

hw: $(WORKDIR)/ipchecksum/behavioral.dat 

comp: 

$(WORKDIR)/ipchecksumtest/behavioral.dat: $(WORKDIR)/touched ipchecksumtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ipchecksumtest.vhd

sim: $(WORKDIR)/ipchecksumtest/behavioral.dat 
runsim: all
	$(VHDLS) ipchecksumtest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
