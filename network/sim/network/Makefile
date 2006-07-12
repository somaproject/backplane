VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/prim.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/somabackplane/prim.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/ipchecksum/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd
	$(VHDLC) ../../vhdl/ipchecksum.vhd

$(WORKDIR)/arpresponse/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/arpresponse.vhd
	$(VHDLC) ../../vhdl/arpresponse.vhd

$(WORKDIR)/eventbodywriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd
	$(VHDLC) ../../vhdl/eventbodywriter.vhd

$(WORKDIR)/eventheaderwriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventheaderwriter.vhd
	$(VHDLC) ../../vhdl/eventheaderwriter.vhd

$(WORKDIR)/eventtx/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventheaderwriter.vhd ../../vhdl/eventtx.vhd
	$(VHDLC) ../../vhdl/eventtx.vhd

$(WORKDIR)/inputcontrol/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventheaderwriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd
	$(VHDLC) ../../vhdl/inputcontrol.vhd

$(WORKDIR)/pingicmpwriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventheaderwriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd
	$(VHDLC) ../../vhdl/pingicmpwriter.vhd

$(WORKDIR)/pingipwriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventheaderwriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd
	$(VHDLC) ../../vhdl/pingipwriter.vhd

$(WORKDIR)/pingresponse/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventheaderwriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd
	$(VHDLC) ../../vhdl/pingresponse.vhd

$(WORKDIR)/txmux/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventheaderwriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd
	$(VHDLC) ../../vhdl/txmux.vhd

$(WORKDIR)/network/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventheaderwriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/network.vhd
	$(VHDLC) ../../vhdl/network.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/arpresponse/_behavioral.var $(WORKDIR)/eventbodywriter/_behavioral.var $(WORKDIR)/eventheaderwriter/_behavioral.var $(WORKDIR)/eventtx/_behavioral.var $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/pingicmpwriter/_behavioral.var $(WORKDIR)/pingipwriter/_behavioral.var $(WORKDIR)/pingresponse/_behavioral.var $(WORKDIR)/txmux/_behavioral.var $(WORKDIR)/network/_behavioral.var 

comp: 

$(WORKDIR)/networktest/_behavioral.var: networktest.vhd
	$(VHDLC) networktest.vhd

sim: $(WORKDIR)/networktest/_behavioral.var 
runsim: all
	$(VHDLS) networktest


clean:
	rm -Rf $(WORKDIR)$

