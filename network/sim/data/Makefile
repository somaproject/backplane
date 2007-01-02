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

$(WORKDIR)/ipchecksum/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/dataacquire.vhd ../../vhdl/ipchecksum.vhd
	$(VHDLC) ../../vhdl/ipchecksum.vhd

$(WORKDIR)/udpheaderwriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/dataacquire.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd
	$(VHDLC) ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/datapacketgen/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/dataacquire.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/datapacketgen.vhd
	$(VHDLC) ../../vhdl/datapacketgen.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/dataacquire/_behavioral.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/udpheaderwriter/_behavioral.var $(WORKDIR)/datapacketgen/_behavioral.var 

comp: 

$(WORKDIR)/datapacketgentest/_behavioral.var: datapacketgentest.vhd
	$(VHDLC) datapacketgentest.vhd

sim: $(WORKDIR)/datapacketgentest/_behavioral.var 
runsim: all
	$(VHDLS) datapacketgentest


clean:
	rm -Rf $(WORKDIR)$

