VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

soma.sym/somabackplane/prim.var: ../../../vhdl/somabackplane.vhd
	$(VHDLC) -vital2000 -work soma  ../../../vhdl/somabackplane.vhd

$(WORKDIR)/netports/prim.var: ../../vhdl/netports.vhd
	$(VHDLC) -vital2000 ../../vhdl/netports.vhd

$(WORKDIR)/networkstack/prim.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd
	$(VHDLC) -vital2000 ../../vhdl/networkstack.vhd

$(WORKDIR)/eventbodywriter/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/eventbodywriter.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventbodywriter.vhd

$(WORKDIR)/ipchecksum/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd
	$(VHDLC) -vital2000 ../../vhdl/ipchecksum.vhd

$(WORKDIR)/udpheaderwriter/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd
	$(VHDLC) -vital2000 ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/eventtxpkfifo/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventtxpkfifo.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventtxpkfifo.vhd

$(WORKDIR)/bitcnt/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventtxpkfifo.vhd ../../vhdl/bitcnt.vhd
	$(VHDLC) -vital2000 ../../vhdl/bitcnt.vhd

$(WORKDIR)/eventtx/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/eventtxpkfifo.vhd ../../vhdl/bitcnt.vhd ../../vhdl/eventtx.vhd
	$(VHDLC) -vital2000 ../../vhdl/eventtx.vhd

hw: soma.sym/somabackplane/prim.var $(WORKDIR)/netports/prim.var $(WORKDIR)/networkstack/prim.var $(WORKDIR)/eventbodywriter/_behavioral.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/udpheaderwriter/_behavioral.var $(WORKDIR)/eventtxpkfifo/_behavioral.var $(WORKDIR)/bitcnt/_behavioral.var $(WORKDIR)/eventtx/_behavioral.var 

comp: 

$(WORKDIR)/eventtxtest/_behavioral.var: eventtxtest.vhd
	$(VHDLC) -vital2000 eventtxtest.vhd

sim: $(WORKDIR)/eventtxtest/_behavioral.var 
runsim: all
	$(VHDLS) eventtxtest


clean:
	rm -Rf *.sym

