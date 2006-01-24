VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/_body.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) ../../vhdl/somabackplane.vhd

$(WORKDIR)/routecore/_behavioral.var: ../../vhdl/core/routecore.vhd
	$(VHDLC) ../../vhdl/core/routecore.vhd

hw: $(WORKDIR)/somabackplane/_body.var $(WORKDIR)/routecore/_behavioral.var 

comp: 

$(WORKDIR)/routecoretest/_behavior.var: routecoretest.vhd
	$(VHDLC) routecoretest.vhd

sim: $(WORKDIR)/routecoretest/_behavior.var 
runsim: all
	$(VHDLS) routecoretest


clean:
	rm -Rf $(WORKDIR)$

