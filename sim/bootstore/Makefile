VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/prim.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) -vital2000 ../../vhdl/somabackplane.vhd

$(WORKDIR)/bootspiio/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/bootspiio.vhd
	$(VHDLC) -vital2000 ../../vhdl/bootspiio.vhd

$(WORKDIR)/bootstore/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/bootspiio.vhd ../../vhdl/bootstore.vhd
	$(VHDLC) -vital2000 ../../vhdl/bootstore.vhd

$(WORKDIR)/singleeventdesttx/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/bootspiio.vhd ../../vhdl/bootstore.vhd ../../vhdl/singleeventdesttx.vhd
	$(VHDLC) -vital2000 ../../vhdl/singleeventdesttx.vhd

$(WORKDIR)/rxeventfifo/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/bootspiio.vhd ../../vhdl/bootstore.vhd ../../vhdl/singleeventdesttx.vhd ../../vhdl/rxeventfifo.vhd
	$(VHDLC) -vital2000 ../../vhdl/rxeventfifo.vhd

hw: $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/bootspiio/_behavioral.var $(WORKDIR)/bootstore/_behavioral.var $(WORKDIR)/singleeventdesttx/_behavioral.var $(WORKDIR)/rxeventfifo/_behavioral.var 

comp: 

$(WORKDIR)/bootstoretest/_behavioral.var: bootstoretest.vhd
	$(VHDLC) -vital2000 bootstoretest.vhd

sim: $(WORKDIR)/bootstoretest/_behavioral.var 
runsim: all
	$(VHDLS) bootstoretest


clean:
	rm -Rf *.sym

