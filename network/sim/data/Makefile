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

$(WORKDIR)/dataacquire/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd
	$(VHDLC) -vital2000 ../../vhdl/dataacquire.vhd

$(WORKDIR)/bigmem/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd
	$(VHDLC) -vital2000 ../../vhdl/bigmem.vhd

$(WORKDIR)/dataretxbuf/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd
	$(VHDLC) -vital2000 ../../vhdl/dataretxbuf.vhd

$(WORKDIR)/datafifo/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd
	$(VHDLC) -vital2000 ../../vhdl/datafifo.vhd

$(WORKDIR)/ipchecksum/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd ../../vhdl/ipchecksum.vhd
	$(VHDLC) -vital2000 ../../vhdl/ipchecksum.vhd

$(WORKDIR)/udpheaderwriter/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd
	$(VHDLC) -vital2000 ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/datapacketgen/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/datapacketgen.vhd
	$(VHDLC) -vital2000 ../../vhdl/datapacketgen.vhd

$(WORKDIR)/data/_behavioral.var: ../../vhdl/netports.vhd ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/data.vhd
	$(VHDLC) -vital2000 ../../vhdl/data.vhd

hw: soma.sym/somabackplane/prim.var $(WORKDIR)/netports/prim.var $(WORKDIR)/networkstack/prim.var $(WORKDIR)/dataacquire/_behavioral.var $(WORKDIR)/bigmem/_behavioral.var $(WORKDIR)/dataretxbuf/_behavioral.var $(WORKDIR)/datafifo/_behavioral.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/udpheaderwriter/_behavioral.var $(WORKDIR)/datapacketgen/_behavioral.var $(WORKDIR)/data/_behavioral.var 

comp: 

$(WORKDIR)/datatest/_behavioral.var: datatest.vhd
	$(VHDLC) -vital2000 datatest.vhd

sim: $(WORKDIR)/datatest/_behavioral.var 
runsim: all
	$(VHDLS) datatest


clean:
	rm -Rf *.sym

