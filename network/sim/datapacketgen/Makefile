VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

soma.sym/somabackplane/prim.var: ../../../vhdl/somabackplane.vhd
	$(VHDLC) -vital2000 -work soma  ../../../vhdl/somabackplane.vhd

$(WORKDIR)/networkstack/prim.var: ../../vhdl/networkstack.vhd
	$(VHDLC) -vital2000 ../../vhdl/networkstack.vhd

$(WORKDIR)/dataacquire/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd
	$(VHDLC) -vital2000 ../../vhdl/dataacquire.vhd

$(WORKDIR)/ipchecksum/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/ipchecksum.vhd
	$(VHDLC) -vital2000 ../../vhdl/ipchecksum.vhd

$(WORKDIR)/udpheaderwriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd
	$(VHDLC) -vital2000 ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/datapacketgen/_behavioral.var: ../../vhdl/networkstack.vhd ../../vhdl/dataacquire.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/datapacketgen.vhd
	$(VHDLC) -vital2000 ../../vhdl/datapacketgen.vhd

hw: soma.sym/somabackplane/prim.var $(WORKDIR)/networkstack/prim.var $(WORKDIR)/dataacquire/_behavioral.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/udpheaderwriter/_behavioral.var $(WORKDIR)/datapacketgen/_behavioral.var 

comp: 

$(WORKDIR)/datapacketgentest/_behavioral.var: datapacketgentest.vhd
	$(VHDLC) -vital2000 datapacketgentest.vhd

sim: $(WORKDIR)/datapacketgentest/_behavioral.var 
runsim: all
	$(VHDLS) datapacketgentest


clean:
	rm -Rf *.sym

