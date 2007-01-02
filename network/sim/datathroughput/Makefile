VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/prim.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/somabackplane/prim.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/dataacquire/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/dataacquire.vhd
	$(VHDLC) ../../vhdl/dataacquire.vhd

$(WORKDIR)/bigmem/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd
	$(VHDLC) ../../vhdl/bigmem.vhd

$(WORKDIR)/dataretxbuf/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd
	$(VHDLC) ../../vhdl/dataretxbuf.vhd

$(WORKDIR)/datafifo/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd
	$(VHDLC) ../../vhdl/datafifo.vhd

$(WORKDIR)/ipchecksum/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd ../../vhdl/ipchecksum.vhd
	$(VHDLC) ../../vhdl/ipchecksum.vhd

$(WORKDIR)/udpheaderwriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd
	$(VHDLC) ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/datapacketgen/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/datapacketgen.vhd
	$(VHDLC) ../../vhdl/datapacketgen.vhd

$(WORKDIR)/data/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/dataacquire.vhd ../../vhdl/bigmem.vhd ../../vhdl/dataretxbuf.vhd ../../vhdl/datafifo.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/data.vhd
	$(VHDLC) ../../vhdl/data.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/dataacquire/_behavioral.var $(WORKDIR)/bigmem/_behavioral.var $(WORKDIR)/dataretxbuf/_behavioral.var $(WORKDIR)/datafifo/_behavioral.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/udpheaderwriter/_behavioral.var $(WORKDIR)/datapacketgen/_behavioral.var $(WORKDIR)/data/_behavioral.var 

comp: 

$(WORKDIR)/datathroughputtest/_behavioral.var: datathroughputtest.vhd
	$(VHDLC) datathroughputtest.vhd

sim: $(WORKDIR)/datathroughputtest/_behavioral.var 
runsim: all
	$(VHDLS) datathroughputtest


clean:
	rm -Rf $(WORKDIR)$

