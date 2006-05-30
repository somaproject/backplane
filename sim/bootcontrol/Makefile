VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/_body.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) ../../vhdl/somabackplane.vhd

$(WORKDIR)/rxeventfifo/_behavioral.var: ../../vhdl/rxeventfifo.vhd
	$(VHDLC) ../../vhdl/rxeventfifo.vhd

$(WORKDIR)/bootcontrol/_behavioral.var: ../../vhdl/bootcontrol.vhd
	$(VHDLC) ../../vhdl/bootcontrol.vhd

hw: $(WORKDIR)/somabackplane/_body.var $(WORKDIR)/rxeventfifo/_behavioral.var $(WORKDIR)/bootcontrol/_behavioral.var 

comp: 

$(WORKDIR)/bootcontroltest/_behavioral.var: bootcontroltest.vhd
	$(VHDLC) bootcontroltest.vhd

sim: $(WORKDIR)/bootcontroltest/_behavioral.var 
runsim: all
	$(VHDLS) bootcontroltest


clean:
	rm -Rf $(WORKDIR)$

