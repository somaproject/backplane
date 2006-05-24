VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/_body.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) ../../vhdl/somabackplane.vhd

$(WORKDIR)/rxeventfifo/_behavioral.var: ../../vhdl/rxeventfifo.vhd
	$(VHDLC) ../../vhdl/rxeventfifo.vhd

hw: $(WORKDIR)/somabackplane/_body.var $(WORKDIR)/rxeventfifo/_behavioral.var 

comp: 

$(WORKDIR)/rxeventfifotest/_behavioral.var: rxeventfifotest.vhd
	$(VHDLC) rxeventfifotest.vhd

sim: $(WORKDIR)/rxeventfifotest/_behavioral.var 
runsim: all
	$(VHDLS) rxeventfifotest


clean:
	rm -Rf $(WORKDIR)$

