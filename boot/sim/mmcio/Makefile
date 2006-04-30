VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/byteio/_behavioral.var: ../../vhdl/byteio.vhd
	$(VHDLC) ../../vhdl/byteio.vhd

$(WORKDIR)/mmcio/_behavioral.var: ../../vhdl/mmcio.vhd
	$(VHDLC) ../../vhdl/mmcio.vhd

hw: $(WORKDIR)/byteio/_behavioral.var $(WORKDIR)/mmcio/_behavioral.var 

$(WORKDIR)/mmc/_behavioral.var: ../components/mmc/mmc.vhd
	$(VHDLC) ../components/mmc/mmc.vhd

comp: $(WORKDIR)/mmc/_behavioral.var 

$(WORKDIR)/mmciotest/_behavioral.var: mmciotest.vhd
	$(VHDLC) mmciotest.vhd

sim: $(WORKDIR)/mmciotest/_behavioral.var 
runsim: all
	$(VHDLS) mmciotest


clean:
	rm -Rf $(WORKDIR)$

