VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/prim.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) -vital2000 ../../vhdl/somabackplane.vhd

$(WORKDIR)/bootserialize/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/bootserialize.vhd
	$(VHDLC) -vital2000 ../../vhdl/bootserialize.vhd

$(WORKDIR)/bootserperipheral/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/bootserialize.vhd ../../vhdl/bootserperipheral.vhd
	$(VHDLC) -vital2000 ../../vhdl/bootserperipheral.vhd

$(WORKDIR)/regfile/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/bootserialize.vhd ../../vhdl/bootserperipheral.vhd ../../eproc/vhdl/regfile.vhd
	$(VHDLC) -vital2000 ../../eproc/vhdl/regfile.vhd

$(WORKDIR)/bootdeserialize/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/bootserialize.vhd ../../vhdl/bootserperipheral.vhd ../../eproc/vhdl/regfile.vhd ../components/bootdeser/bootdeserialize.vhd
	$(VHDLC) -vital2000 ../components/bootdeser/bootdeserialize.vhd

hw: $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/bootserialize/_behavioral.var $(WORKDIR)/bootserperipheral/_behavioral.var $(WORKDIR)/regfile/_behavioral.var $(WORKDIR)/bootdeserialize/_behavioral.var 

comp: 

$(WORKDIR)/bootserializetest/_behavioral.var: bootserializetest.vhd
	$(VHDLC) -vital2000 bootserializetest.vhd

sim: $(WORKDIR)/bootserializetest/_behavioral.var 
runsim: all
	$(VHDLS) bootserializetest


clean:
	rm -Rf *.sym

