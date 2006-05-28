VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/_body.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) ../../vhdl/somabackplane.vhd

$(WORKDIR)/bootserialize/_behavioral.var: ../../vhdl/bootserialize.vhd
	$(VHDLC) ../../vhdl/bootserialize.vhd

$(WORKDIR)/bootdeserialize/_behavioral.var: ../components/bootdeser/bootdeserialize.vhd
	$(VHDLC) ../components/bootdeser/bootdeserialize.vhd

hw: $(WORKDIR)/somabackplane/_body.var $(WORKDIR)/bootserialize/_behavioral.var $(WORKDIR)/bootdeserialize/_behavioral.var 

comp: 

$(WORKDIR)/bootserializetest/_behavioral.var: bootserializetest.vhd
	$(VHDLC) bootserializetest.vhd

sim: $(WORKDIR)/bootserializetest/_behavioral.var 
runsim: all
	$(VHDLS) bootserializetest


clean:
	rm -Rf $(WORKDIR)$

