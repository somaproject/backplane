VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/_somabackplane.var: ../../../vhdl/somabackplane.vhd
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/datamempktinput/_behavioral.var: ../../vhdl/datamempktinput.vhd
	$(VHDLC) ../../vhdl/datamempktinput.vhd

hw: $(WORKDIR)/somabackplane/_somabackplane.var $(WORKDIR)/datamempktinput/_behavioral.var 

comp: 

$(WORKDIR)/datamempktinputtest/_behavioral.var: datamempktinputtest.vhd
	$(VHDLC) datamempktinputtest.vhd

sim: $(WORKDIR)/datamempktinputtest/_behavioral.var 
runsim: all
	$(VHDLS) datamempktinputtest


clean:
	rm -Rf $(WORKDIR)$

