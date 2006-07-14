VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/_networkstack.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/somabackplane/_somabackplane.var: ../../../vhdl/somabackplane.vhd
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/eventbodywriter/_behavioral.var: ../../vhdl/eventbodywriter.vhd
	$(VHDLC) ../../vhdl/eventbodywriter.vhd

$(WORKDIR)/ipchecksum/_behavioral.var: ../../vhdl/ipchecksum.vhd
	$(VHDLC) ../../vhdl/ipchecksum.vhd

$(WORKDIR)/eventheaderwriter/_behavioral.var: ../../vhdl/eventheaderwriter.vhd
	$(VHDLC) ../../vhdl/eventheaderwriter.vhd

$(WORKDIR)/eventtx/_behavioral.var: ../../vhdl/eventtx.vhd
	$(VHDLC) ../../vhdl/eventtx.vhd

hw: $(WORKDIR)/networkstack/_networkstack.var $(WORKDIR)/somabackplane/_somabackplane.var $(WORKDIR)/eventbodywriter/_behavioral.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/eventheaderwriter/_behavioral.var $(WORKDIR)/eventtx/_behavioral.var 

comp: 

$(WORKDIR)/eventtxtest/_behavioral.var: eventtxtest.vhd
	$(VHDLC) eventtxtest.vhd

sim: $(WORKDIR)/eventtxtest/_behavioral.var 
runsim: all
	$(VHDLS) eventtxtest


clean:
	rm -Rf $(WORKDIR)$

