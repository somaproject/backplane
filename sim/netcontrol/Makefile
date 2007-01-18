VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/prim.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) -vital2000 ../../vhdl/somabackplane.vhd

$(WORKDIR)/rxeventfifo/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/rxeventfifo.vhd
	$(VHDLC) -vital2000 ../../vhdl/rxeventfifo.vhd

$(WORKDIR)/txcounter/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/rxeventfifo.vhd ../../vhdl/netcontrol/txcounter.vhd
	$(VHDLC) -vital2000 ../../vhdl/netcontrol/txcounter.vhd

$(WORKDIR)/netcontrol/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/rxeventfifo.vhd ../../vhdl/netcontrol/txcounter.vhd ../../vhdl/netcontrol/netcontrol.vhd
	$(VHDLC) -vital2000 ../../vhdl/netcontrol/netcontrol.vhd

hw: $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/rxeventfifo/_behavioral.var $(WORKDIR)/txcounter/_behavioral.var $(WORKDIR)/netcontrol/_behavioral.var 

comp: 

$(WORKDIR)/netcontroltest/_behavioral.var: netcontroltest.vhd
	$(VHDLC) -vital2000 netcontroltest.vhd

sim: $(WORKDIR)/netcontroltest/_behavioral.var 
runsim: all
	$(VHDLS) netcontroltest


clean:
	rm -Rf *.sym

