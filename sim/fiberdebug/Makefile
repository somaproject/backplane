VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/prim.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) -vital2000 ../../vhdl/somabackplane.vhd

$(WORKDIR)/rxeventfifo/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/rxeventfifo.vhd
	$(VHDLC) -vital2000 ../../vhdl/rxeventfifo.vhd

$(WORKDIR)/decoder/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/rxeventfifo.vhd ../../vhdl/fiberdebug/decoder.vhd
	$(VHDLC) -vital2000 ../../vhdl/fiberdebug/decoder.vhd

$(WORKDIR)/fiberdebugrx/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/rxeventfifo.vhd ../../vhdl/fiberdebug/decoder.vhd ../../vhdl/fiberdebug/fiberdebugrx.vhd
	$(VHDLC) -vital2000 ../../vhdl/fiberdebug/fiberdebugrx.vhd

$(WORKDIR)/fiberdebugtx/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/rxeventfifo.vhd ../../vhdl/fiberdebug/decoder.vhd ../../vhdl/fiberdebug/fiberdebugrx.vhd ../../vhdl/fiberdebug/fiberdebugtx.vhd
	$(VHDLC) -vital2000 ../../vhdl/fiberdebug/fiberdebugtx.vhd

$(WORKDIR)/fiberdebug/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/rxeventfifo.vhd ../../vhdl/fiberdebug/decoder.vhd ../../vhdl/fiberdebug/fiberdebugrx.vhd ../../vhdl/fiberdebug/fiberdebugtx.vhd ../../vhdl/fiberdebug/fiberdebug.vhd
	$(VHDLC) -vital2000 ../../vhdl/fiberdebug/fiberdebug.vhd

$(WORKDIR)/fibertx/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/rxeventfifo.vhd ../../vhdl/fiberdebug/decoder.vhd ../../vhdl/fiberdebug/fiberdebugrx.vhd ../../vhdl/fiberdebug/fiberdebugtx.vhd ../../vhdl/fiberdebug/fiberdebug.vhd ../../vhdl/fiberdebug/fibertx.vhd
	$(VHDLC) -vital2000 ../../vhdl/fiberdebug/fibertx.vhd

$(WORKDIR)/framedis/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/rxeventfifo.vhd ../../vhdl/fiberdebug/decoder.vhd ../../vhdl/fiberdebug/fiberdebugrx.vhd ../../vhdl/fiberdebug/fiberdebugtx.vhd ../../vhdl/fiberdebug/fiberdebug.vhd ../../vhdl/fiberdebug/fibertx.vhd ../../vhdl/fiberdebug/framedis.vhd
	$(VHDLC) -vital2000 ../../vhdl/fiberdebug/framedis.vhd

$(WORKDIR)/txeventbuffer/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/rxeventfifo.vhd ../../vhdl/fiberdebug/decoder.vhd ../../vhdl/fiberdebug/fiberdebugrx.vhd ../../vhdl/fiberdebug/fiberdebugtx.vhd ../../vhdl/fiberdebug/fiberdebug.vhd ../../vhdl/fiberdebug/fibertx.vhd ../../vhdl/fiberdebug/framedis.vhd ../../vhdl/fiberdebug/txeventbuffer.vhd
	$(VHDLC) -vital2000 ../../vhdl/fiberdebug/txeventbuffer.vhd

hw: $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/rxeventfifo/_behavioral.var $(WORKDIR)/decoder/_behavioral.var $(WORKDIR)/fiberdebugrx/_behavioral.var $(WORKDIR)/fiberdebugtx/_behavioral.var $(WORKDIR)/fiberdebug/_behavioral.var $(WORKDIR)/fibertx/_behavioral.var $(WORKDIR)/framedis/_behavioral.var $(WORKDIR)/txeventbuffer/_behavioral.var 

$(WORKDIR)/encode8b10b/_encode8b10b_a.var: encode8b10b.vhd
	$(VHDLC) -vital2000 encode8b10b.vhd

$(WORKDIR)/decode8b10b/_decode8b10b_a.var: encode8b10b.vhd decode8b10b.vhd
	$(VHDLC) -vital2000 decode8b10b.vhd

comp: $(WORKDIR)/encode8b10b/_encode8b10b_a.var $(WORKDIR)/decode8b10b/_decode8b10b_a.var 

$(WORKDIR)/fiberdebugtest/_behavioral.var: encode8b10b.vhd decode8b10b.vhd fiberdebugtest.vhd
	$(VHDLC) -vital2000 fiberdebugtest.vhd

sim: $(WORKDIR)/fiberdebugtest/_behavioral.var 
runsim: all
	$(VHDLS) fiberdebugtest


clean:
	rm -Rf *.sym

