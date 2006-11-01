VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/dqalign/_behavioral.var: ../../../memory/vhdl/dqalign.vhd
	$(VHDLC) ../../../memory/vhdl/dqalign.vhd

$(WORKDIR)/bootddr2/_behavioral.var: ../../../memory/vhdl/bootddr2.vhd
	$(VHDLC) ../../../memory/vhdl/bootddr2.vhd

$(WORKDIR)/readddr2/_behavioral.var: ../../../memory/vhdl/readddr2.vhd
	$(VHDLC) ../../../memory/vhdl/readddr2.vhd

$(WORKDIR)/refreshddr2/_behavioral.var: ../../../memory/vhdl/refreshddr2.vhd
	$(VHDLC) ../../../memory/vhdl/refreshddr2.vhd

$(WORKDIR)/writeddr2/_behavioral.var: ../../../memory/vhdl/writeddr2.vhd
	$(VHDLC) ../../../memory/vhdl/writeddr2.vhd

$(WORKDIR)/memcontmux/_behavioral.var: ../../../memory/vhdl/memcontmux.vhd
	$(VHDLC) ../../../memory/vhdl/memcontmux.vhd

$(WORKDIR)/memddr2/_behavioral.var: ../../../memory/vhdl/memddr2.vhd
	$(VHDLC) ../../../memory/vhdl/memddr2.vhd

$(WORKDIR)/networkstack/_networkstack.var: ../../vhdl/networkstack.vhd
	$(VHDLC) ../../vhdl/networkstack.vhd

$(WORKDIR)/somabackplane/_somabackplane.var: ../../../vhdl/somabackplane.vhd
	$(VHDLC) ../../../vhdl/somabackplane.vhd

$(WORKDIR)/ipchecksum/_behavioral.var: ../../vhdl/ipchecksum.vhd
	$(VHDLC) ../../vhdl/ipchecksum.vhd

$(WORKDIR)/bigmem/_behavioral.var: ../../vhdl/bigmem.vhd
	$(VHDLC) ../../vhdl/bigmem.vhd

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

$(WORKDIR)/datamempktinput/_behavioral.var: ../../vhdl/datamempktinput.vhd
	$(VHDLC) ../../vhdl/datamempktinput.vhd

$(WORKDIR)/datapacketgen/_behavioral.var: ../../vhdl/datapacketgen.vhd
	$(VHDLC) ../../vhdl/datapacketgen.vhd

$(WORKDIR)/datamemarbit/_behavioral.var: ../../vhdl/datamemarbit.vhd
	$(VHDLC) ../../vhdl/datamemarbit.vhd

$(WORKDIR)/datafifo/_behavioral.var: ../../vhdl/datafifo.vhd
	$(VHDLC) ../../vhdl/datafifo.vhd

$(WORKDIR)/dataretxbuf/_behavioral.var: ../../vhdl/dataretxbuf.vhd
	$(VHDLC) ../../vhdl/dataretxbuf.vhd

$(WORKDIR)/dataacquire/_behavioral.var: ../../vhdl/dataacquire.vhd
	$(VHDLC) ../../vhdl/dataacquire.vhd

$(WORKDIR)/data/_behavioral.var: ../../vhdl/data.vhd
	$(VHDLC) ../../vhdl/data.vhd

$(WORKDIR)/retxbuffer/_behavioral.var: ../../vhdl/retxbuffer.vhd
	$(VHDLC) ../../vhdl/retxbuffer.vhd

$(WORKDIR)/network/_behavioral.var: ../../vhdl/network.vhd
	$(VHDLC) ../../vhdl/network.vhd

hw: $(WORKDIR)/dqalign/_behavioral.var $(WORKDIR)/bootddr2/_behavioral.var $(WORKDIR)/readddr2/_behavioral.var $(WORKDIR)/refreshddr2/_behavioral.var $(WORKDIR)/writeddr2/_behavioral.var $(WORKDIR)/memcontmux/_behavioral.var $(WORKDIR)/memddr2/_behavioral.var $(WORKDIR)/networkstack/_networkstack.var $(WORKDIR)/somabackplane/_somabackplane.var $(WORKDIR)/ipchecksum/_behavioral.var $(WORKDIR)/bigmem/_behavioral.var $(WORKDIR)/udpheaderwriter/_behavioral.var $(WORKDIR)/arpresponse/_behavioral.var $(WORKDIR)/eventbodywriter/_behavioral.var $(WORKDIR)/eventtx/_behavioral.var $(WORKDIR)/inputcontrol/_behavioral.var $(WORKDIR)/pingicmpwriter/_behavioral.var $(WORKDIR)/pingipwriter/_behavioral.var $(WORKDIR)/pingresponse/_behavioral.var $(WORKDIR)/txmux/_behavioral.var $(WORKDIR)/retxresponse/_behavioral.var $(WORKDIR)/eventrxbusoutput/_behavioral.var $(WORKDIR)/eventrxresponsewr/_behavioral.var $(WORKDIR)/eventrx/_behavioral.var $(WORKDIR)/datamempktretx/_behavioral.var $(WORKDIR)/datamempkttx/_behavioral.var $(WORKDIR)/datamempktinput/_behavioral.var $(WORKDIR)/datapacketgen/_behavioral.var $(WORKDIR)/datamemarbit/_behavioral.var $(WORKDIR)/datafifo/_behavioral.var $(WORKDIR)/dataretxbuf/_behavioral.var $(WORKDIR)/dataacquire/_behavioral.var $(WORKDIR)/data/_behavioral.var $(WORKDIR)/retxbuffer/_behavioral.var $(WORKDIR)/network/_behavioral.var 

comp: 

$(WORKDIR)/retxreq/_behavioral.var: retxreq.vhd
	$(VHDLC) retxreq.vhd

$(WORKDIR)/datareceiver/_behavioral.var: datareceiver.vhd
	$(VHDLC) datareceiver.vhd

$(WORKDIR)/eventreceiver/_behavioral.var: eventreceiver.vhd
	$(VHDLC) eventreceiver.vhd

$(WORKDIR)/hy5ps121621f_pack/_hy5ps121621f_pack.var: ../../../memory/sim/components/hynix/HY5PS121621F_PACK.vhd
	$(VHDLC) ../../../memory/sim/components/hynix/HY5PS121621F_PACK.vhd

$(WORKDIR)/hy5ps121621f/_behavioral_model_hy5ps121621f.var: ../../../memory/sim/components/hynix/HY5PS121621F.vhd
	$(VHDLC) ../../../memory/sim/components/hynix/HY5PS121621F.vhd

$(WORKDIR)/networktest/_behavioral.var: networktest.vhd
	$(VHDLC) networktest.vhd

sim: $(WORKDIR)/retxreq/_behavioral.var $(WORKDIR)/datareceiver/_behavioral.var $(WORKDIR)/eventreceiver/_behavioral.var $(WORKDIR)/hy5ps121621f_pack/_hy5ps121621f_pack.var $(WORKDIR)/hy5ps121621f/_behavioral_model_hy5ps121621f.var $(WORKDIR)/networktest/_behavioral.var 
runsim: all
	$(VHDLS) networktest


clean:
	rm -Rf $(WORKDIR)$

