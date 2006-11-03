VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/prim.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/somabackplane/prim.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/eventbodywriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/eventbodywriter.vhd
	$(VHDLC) ../../vhdl/eventbodywriter.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/eventbodywriter/_behavioral.var 

comp: 

$(WORKDIR)/eventbodywritertest/_behavioral.var: eventbodywritertest.vhd
	$(VHDLC) eventbodywritertest.vhd

sim: $(WORKDIR)/eventbodywritertest/_behavioral.var 
runsim: all
	$(VHDLS) eventbodywritertest


clean:
	rm -Rf $(WORKDIR)$

