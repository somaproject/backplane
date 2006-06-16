VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/nicserialio/_behavioral.var: ../../vhdl/ether/nicserialio.vhd
	$(VHDLC) ../../vhdl/ether/nicserialio.vhd

hw: $(WORKDIR)/nicserialio/_behavioral.var 

comp: 

$(WORKDIR)/nicserialiotest/_behavioral.var: nicserialiotest.vhd
	$(VHDLC) nicserialiotest.vhd

sim: $(WORKDIR)/nicserialiotest/_behavioral.var 
runsim: all
	$(VHDLS) nicserialiotest


clean:
	rm -Rf $(WORKDIR)$

