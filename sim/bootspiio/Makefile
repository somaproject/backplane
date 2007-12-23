VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/prim.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) -vital2000 ../../vhdl/somabackplane.vhd

$(WORKDIR)/bootspiio/_behavioral.var: ../../vhdl/somabackplane.vhd ../../vhdl/bootspiio.vhd
	$(VHDLC) -vital2000 ../../vhdl/bootspiio.vhd

hw: $(WORKDIR)/somabackplane/prim.var $(WORKDIR)/bootspiio/_behavioral.var 

comp: 

$(WORKDIR)/bootspiiotest/_behavioral.var: bootspiiotest.vhd
	$(VHDLC) -vital2000 bootspiiotest.vhd

sim: $(WORKDIR)/bootspiiotest/_behavioral.var 
runsim: all
	$(VHDLS) bootspiiotest


clean:
	rm -Rf *.sym

