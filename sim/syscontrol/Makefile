VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/_body.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) ../../vhdl/somabackplane.vhd

$(WORKDIR)/rxeventfifo/_behavioral.var: ../../vhdl/rxeventfifo.vhd
	$(VHDLC) ../../vhdl/rxeventfifo.vhd

$(WORKDIR)/syscontrol/_behavioral.var: ../../vhdl/syscontrol.vhd
	$(VHDLC) ../../vhdl/syscontrol.vhd

hw: $(WORKDIR)/somabackplane/_body.var $(WORKDIR)/rxeventfifo/_behavioral.var $(WORKDIR)/syscontrol/_behavioral.var 

comp: 

$(WORKDIR)/syscontroltest/_behavioral.var: syscontroltest.vhd
	$(VHDLC) syscontroltest.vhd

sim: $(WORKDIR)/syscontroltest/_behavioral.var 
runsim: all
	$(VHDLS) syscontroltest


clean:
	rm -Rf $(WORKDIR)$

