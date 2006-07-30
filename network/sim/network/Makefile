VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/networkstack/_networkstack.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/somabackplane/_somabackplane.var: ../../../vhdl/somabackplane.vhd
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/ipchecksum/_behavioral.var: ../../vhdl/ipchecksum.vhd
	$(VHDLC) ../../vhdl/ipchecksum.vhd

$(WORKDIR)/udpheaderwriter/_behavioral.var: ../../vhdl/udpheaderwriter.vhd
	$(VHDLC) ../../vhdl/udpheaderwriter.vhd

$(WORKDIR)/arpresponse/_behavioral.var: ../../vhdl/arpresponse.vhd
	$(VHDLC) ../../vhdl/arpresponse.vhd

$(WORKDIR)/eventbodywriter/_behavioral.var: ../../vhdl/eventbodywriter.vhd
	$(VHDLC) ../../vhdl/eventbodywriter.vhd

$(WORKDIR)/eventtx/_behavioral.var: ../../vhdl/eventtx.vhd
	$(VHDLC) ../../vhdl/eventtx.vhd

$(WORKDIR)/inputcontrol/_behavioral.var: ../../vhdl/inputcontrol.vhd
	$(VHDLC) ../../vhdl/inputcontrol.vhd

$(WORKDIR)/pingicmpwriter/_behavioral.var: ../../vhdl/pingicmpwriter.vhd
	$(VHDLC) ../../vhdl/pingicmpwriter.vhd

$(WORKDIR)/pingipwriter/_behavioral.var: ../../vhdl/pingipwriter.vhd
	$(VHDLC) ../../vhdl/pingipwriter.vhd

$(WORKDIR)/pingresponse/_behavioral.var: ../../vhdl/pingresponse.vhd
	$(VHDLC) ../../vhdl/pingresponse.vhd

$(WORKDIR)/txmux/_behavioral.var: ../../vhdl/txmux.vhd
	$(VHDLC) ../../vhdl/txmux.vhd

$(WORKDIR)/retxresponse/_behavioral.var: ../../vhdl/retxresponse.vhd
	$(VHDLC) ../../vhdl/retxresponse.vhd

$(WORKDIR)/retx/_behavioral.var: ../../vhdl/retx.vhd
	$(VHDLC) ../../vhdl/retx.vhd

$(WORKDIR)/eventrxbusoutput/_behavioral.var: ../../vhdl/eventrxbusoutput.vhd
	$(VHDLC) ../../vhdl/eventrxbusoutput.vhd

$(WORKDIR)/eventrxresponsewr/_behavioral.var: ../../vhdl/eventrxresponsewr.vhd
	$(VHDLC) ../../vhdl/eventrxresponsewr.vhd

$(WORKDIR)/eventrx/_behavioral.var: ../../vhdl/eventrx.vhd
	$(VHDLC) ../../vhdl/eventrx.vhd

$(WORKDIR)/datamempktretx/_behavioral.var: ../../vhdl/datamempktretx.vhd
	$(VHDLC) ../../vhdl/datamempktretx.vhd

$(WORKDIR)/datamempkttx/_behavioral.var: ../../vhdl/datamempkttx.vhd
	$(VHDLC) ../../vhdl/datamempkttx.vhd

$(WORKDIR)/datapacketgen/_behavioral.var: ../../vhdl/datapacketgen.vhd
	$(VHDLC) ../../vhdl/datapacketgen.vhd

$(WORKDIR)/datamemarbit/_behavioral.var: ../../vhdl/datamemarbit.vhd
	$(VHDLC) ../../vhdl/datamemarbit.vhd

$(WORKDIR)/datafifo/_behavioral.var: ../../vhdl/datafifo.vhd
	$(VHDLC) ../../vhdl/datafifo.vhd

$(WORKDIR)/dataacquire/_behavioral.var: ../../vhdl/dataacquire.vhd
	$(VHDLC) ../../vhdl/dataacquire.vhd

$(WORKDIR)/data/_behavioral.var: ../../vhdl/data.vhd
	$(VHDLC) ../../vhdl/data.vhd

$(WORKDIR)/network/_behavioral.var: ../../vhdl/network.vhd
	$(VHDLC) ../../vhdl/network.vhd

hw: $(WORKDIR)/networkstack/_networkstack.var $(WORKDIR)/somabackplane/_somabackplane.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/udpheaderwriter/_behavioral.var $(WORKDIR)/arpresponse/_behavioral.var $(WORKDIR)/eventbodywriter/_behavioral.var $(WORKDIR)/eventtx/_behavioral.var $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/pingicmpwriter/_behavioral.var $(WORKDIR)/pingipwriter/_behavioral.var $(WORKDIR)/pingresponse/_behavioral.var $(WORKDIR)/txmux/_behavioral.var $(WORKDIR)/retxresponse/_behavioral.var $(WORKDIR)/retx/_behavioral.var $(WORKDIR)/eventrxbusoutput/_behavioral.var $(WORKDIR)/eventrxresponsewr/_behavioral.var $(WORKDIR)/eventrx/_behavioral.var $(WORKDIR)/datamempktretx/_behavioral.var $(WORKDIR)/datamempkttx/_behavioral.var $(WORKDIR)/datapacketgen/_behavioral.var $(WORKDIR)/datamemarbit/_behavioral.var $(WORKDIR)/datafifo/_behavioral.var $(WORKDIR)/dataacquire/_behavioral.var $(WORKDIR)/data/_behavioral.var $(WORKDIR)/network/_behavioral.var 

comp: 

$(WORKDIR)/networktest/_behavioral.var: networktest.vhd
	$(VHDLC) networktest.vhd

sim: $(WORKDIR)/networktest/_behavioral.var 
runsim: all
	$(VHDLS) networktest


clean:
	rm -Rf $(WORKDIR)$

