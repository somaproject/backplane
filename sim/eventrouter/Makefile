VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/prim.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) ../../vhdl/somabackplane.vhd

$(WORKDIR)/eventrouter/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/core/eventrouter.vhd
	$(VHDLC) ../../vhdl/core/eventrouter.vhd

hw: $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/eventrouter/_behavioral.var 

comp: 

$(WORKDIR)/eventroutertest/_behavioral.var: eventroutertest.vhd
	$(VHDLC) eventroutertest.vhd

sim: $(WORKDIR)/eventroutertest/_behavioral.var 
runsim: all
	$(VHDLS) eventroutertest


clean:
	rm -Rf $(WORKDIR)$

