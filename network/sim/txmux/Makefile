VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/networkstack/body.dat: $(WORKDIR)/touched ../../vhdl/networkstack.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/txmux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/networkstack.vhd ../../vhdl/networkstack.vhd ../../vhdl/txmux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/txmux.vhd

hw: $(WORKDIR)/networkstack/body.dat $(WORKDIR)/txmux/behavioral.dat 

comp: 

$(WORKDIR)/txmuxtest/behavioral.dat: $(WORKDIR)/touched txmuxtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) txmuxtest.vhd

sim: $(WORKDIR)/txmuxtest/behavioral.dat 
runsim: all
	$(VHDLS) txmuxtest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
