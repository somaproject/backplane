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

$(WORKDIR)/udpheaderwriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd
	$(VHDLC) ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/arpresponse/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd
	$(VHDLC) ../../vhdl/arpresponse.vhd

$(WORKDIR)/eventbodywriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd
	$(VHDLC) ../../vhdl/eventbodywriter.vhd

$(WORKDIR)/eventtx/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd
	$(VHDLC) ../../vhdl/eventtx.vhd

$(WORKDIR)/inputcontrol/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd
	$(VHDLC) ../../vhdl/inputcontrol.vhd

$(WORKDIR)/pingicmpwriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd
	$(VHDLC) ../../vhdl/pingicmpwriter.vhd

$(WORKDIR)/pingipwriter/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd
	$(VHDLC) ../../vhdl/pingipwriter.vhd

$(WORKDIR)/pingresponse/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd
	$(VHDLC) ../../vhdl/pingresponse.vhd

$(WORKDIR)/txmux/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd
	$(VHDLC) ../../vhdl/txmux.vhd

$(WORKDIR)/retxresponse/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd
	$(VHDLC) ../../vhdl/retxresponse.vhd

$(WORKDIR)/retx/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd ../../vhdl/retx.vhd
	$(VHDLC) ../../vhdl/retx.vhd

$(WORKDIR)/eventrxbusoutput/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd ../../vhdl/retx.vhd ../../vhdl/eventrxbusoutput.vhd
	$(VHDLC) ../../vhdl/eventrxbusoutput.vhd

$(WORKDIR)/eventrxresponsewr/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd ../../vhdl/retx.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd
	$(VHDLC) ../../vhdl/eventrxresponsewr.vhd

$(WORKDIR)/eventrx/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd ../../vhdl/retx.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd
	$(VHDLC) ../../vhdl/eventrx.vhd

$(WORKDIR)/datamempktretx/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd ../../vhdl/retx.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd
	$(VHDLC) ../../vhdl/datamempktretx.vhd

$(WORKDIR)/datamempkttx/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd ../../vhdl/retx.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd
	$(VHDLC) ../../vhdl/datamempkttx.vhd

$(WORKDIR)/datamempktinput/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd ../../vhdl/retx.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd
	$(VHDLC) ../../vhdl/datamempktinput.vhd

$(WORKDIR)/datapacketgen/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd ../../vhdl/retx.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd
	$(VHDLC) ../../vhdl/datapacketgen.vhd

$(WORKDIR)/datamemarbit/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd ../../vhdl/retx.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd
	$(VHDLC) ../../vhdl/datamemarbit.vhd

$(WORKDIR)/datafifo/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd ../../vhdl/retx.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd ../../vhdl/datafifo.vhd
	$(VHDLC) ../../vhdl/datafifo.vhd

$(WORKDIR)/dataacquire/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd ../../vhdl/retx.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataacquire.vhd
	$(VHDLC) ../../vhdl/dataacquire.vhd

$(WORKDIR)/data/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd ../../vhdl/retx.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataacquire.vhd ../../vhdl/data.vhd
	$(VHDLC) ../../vhdl/data.vhd

$(WORKDIR)/network/_behavioral.var: ../../vhdl/networkstack.vhd ../../../vhdl/somabackplane.vhd ../../vhdl/ipchecksum.vhd ../../vhdl/udpheaderwriter.vhd ../../vhdl/arpresponse.vhd ../../vhdl/eventbodywriter.vhd ../../vhdl/eventtx.vhd ../../vhdl/inputcontrol.vhd ../../vhdl/pingicmpwriter.vhd ../../vhdl/pingipwriter.vhd ../../vhdl/pingresponse.vhd ../../vhdl/txmux.vhd ../../vhdl/retxresponse.vhd ../../vhdl/retx.vhd ../../vhdl/eventrxbusoutput.vhd ../../vhdl/eventrxresponsewr.vhd ../../vhdl/eventrx.vhd ../../vhdl/datamempktretx.vhd ../../vhdl/datamempkttx.vhd ../../vhdl/datamempktinput.vhd ../../vhdl/datapacketgen.vhd ../../vhdl/datamemarbit.vhd ../../vhdl/datafifo.vhd ../../vhdl/dataacquire.vhd ../../vhdl/data.vhd ../../vhdl/network.vhd
	$(VHDLC) ../../vhdl/network.vhd

hw: $(WORKDIR)/networkstack/prim.var $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/udpheaderwriter/_behavioral.var $(WORKDIR)/arpresponse/_behavioral.var $(WORKDIR)/eventbodywriter/_behavioral.var $(WORKDIR)/eventtx/_behavioral.var $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/pingicmpwriter/_behavioral.var $(WORKDIR)/pingipwriter/_behavioral.var $(WORKDIR)/pingresponse/_behavioral.var $(WORKDIR)/txmux/_behavioral.var $(WORKDIR)/retxresponse/_behavioral.var $(WORKDIR)/retx/_behavioral.var $(WORKDIR)/eventrxbusoutput/_behavioral.var $(WORKDIR)/eventrxresponsewr/_behavioral.var $(WORKDIR)/eventrx/_behavioral.var $(WORKDIR)/datamempktretx/_behavioral.var $(WORKDIR)/datamempkttx/_behavioral.var $(WORKDIR)/datamempktinput/_behavioral.var $(WORKDIR)/datapacketgen/_behavioral.var $(WORKDIR)/datamemarbit/_behavioral.var $(WORKDIR)/datafifo/_behavioral.var $(WORKDIR)/dataacquire/_behavioral.var $(WORKDIR)/data/_behavioral.var $(WORKDIR)/network/_behavioral.var 

comp: 

$(WORKDIR)/datareceiver/_behavioral.var: datareceiver.vhd
	$(VHDLC) datareceiver.vhd

$(WORKDIR)/eventreceiver/_behavioral.var: datareceiver.vhd eventreceiver.vhd
	$(VHDLC) eventreceiver.vhd

$(WORKDIR)/networktest/_behavioral.var: datareceiver.vhd eventreceiver.vhd networktest.vhd
	$(VHDLC) networktest.vhd

sim: $(WORKDIR)/datareceiver/_behavioral.var $(WORKDIR)/eventreceiver/_behavioral.var $(WORKDIR)/networktest/_behavioral.var 
runsim: all
	$(VHDLS) networktest


clean:
	rm -Rf $(WORKDIR)$

