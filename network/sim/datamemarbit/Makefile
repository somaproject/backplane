VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/_networkstack.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/somabackplane/_somabackplane.var: ../../../vhdl/somabackplane.vhd
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/datamempktretx/_behavioral.var: ../../vhdl/datamempktretx.vhd
	$(VHDLC) ../../vhdl/datamempktretx.vhd

$(WORKDIR)/datamempkttx/_behavioral.var: ../../vhdl/datamempkttx.vhd
	$(VHDLC) ../../vhdl/datamempkttx.vhd

$(WORKDIR)/datamempktinput/_behavioral.var: ../../vhdl/datamempktinput.vhd
	$(VHDLC) ../../vhdl/datamempktinput.vhd

$(WORKDIR)/datamemarbit/_behavioral.var: ../../vhdl/datamemarbit.vhd
	$(VHDLC) ../../vhdl/datamemarbit.vhd

hw: $(WORKDIR)/networkstack/_networkstack.var $(WORKDIR)/somabackplane/_somabackplane.var $(WORKDIR)/datamempktretx/_behavioral.var $(WORKDIR)/datamempkttx/_behavioral.var $(WORKDIR)/datamempktinput/_behavioral.var $(WORKDIR)/datamemarbit/_behavioral.var 

comp: 

$(WORKDIR)/datamemarbittest/_behavioral.var: datamemarbittest.vhd
	$(VHDLC) datamemarbittest.vhd

sim: $(WORKDIR)/datamemarbittest/_behavioral.var 
runsim: all
	$(VHDLS) datamemarbittest


clean:
	rm -Rf $(WORKDIR)$

