VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/prim.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) ../../vhdl/somabackplane.vhd

$(WORKDIR)/rxeventfifo/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/rxeventfifo.vhd
	$(VHDLC) ../../vhdl/rxeventfifo.vhd

$(WORKDIR)/ethercontrol/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/rxeventfifo.vhd ../../vhdl/ether/ethercontrol.vhd
	$(VHDLC) ../../vhdl/ether/ethercontrol.vhd

hw: $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/rxeventfifo/_behavioral.var $(WORKDIR)/ethercontrol/_behavioral.var 

comp: 

$(WORKDIR)/ethercontroltest/_behavioral.var: ethercontroltest.vhd
	$(VHDLC) ethercontroltest.vhd

sim: $(WORKDIR)/ethercontroltest/_behavioral.var 
runsim: all
	$(VHDLS) ethercontroltest


clean:
	rm -Rf $(WORKDIR)$

