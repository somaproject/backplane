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

$(WORKDIR)/ipchecksum/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd
	$(VHDLC) ../../vhdl/ipchecksum.vhd

$(WORKDIR)/udpheaderwriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd
	$(VHDLC) ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/eventtxpkfifo/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventtxpkfifo.vhd
	$(VHDLC) ../../vhdl/eventtxpkfifo.vhd

$(WORKDIR)/bitcnt/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventtxpkfifo.vhd ../../vhdl/bitcnt.vhd
	$(VHDLC) ../../vhdl/bitcnt.vhd

$(WORKDIR)/eventtx/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventtxpkfifo.vhd ../../vhdl/bitcnt.vhd ../../vhdl/eventtx.vhd
	$(VHDLC) ../../vhdl/eventtx.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/eventbodywriter/_behavioral.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/udpheaderwriter/_behavioral.var $(WORKDIR)/eventtxpkfifo/_behavioral.var $(WORKDIR)/bitcnt/_behavioral.var $(WORKDIR)/eventtx/_behavioral.var 

comp: 

$(WORKDIR)/eventtxtest/_behavioral.var: eventtxtest.vhd
	$(VHDLC) eventtxtest.vhd

sim: $(WORKDIR)/eventtxtest/_behavioral.var 
runsim: all
	$(VHDLS) eventtxtest


clean:
	rm -Rf $(WORKDIR)$

