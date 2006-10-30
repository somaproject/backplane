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

$(WORKDIR)/retxbuffer/_behavioral.var: ../../vhdl/retxbuffer.vhd
	$(VHDLC) ../../vhdl/retxbuffer.vhd

hw: $(WORKDIR)/dqalign/_behavioral.var $(WORKDIR)/bootddr2/_behavioral.var $(WORKDIR)/readddr2/_behavioral.var $(WORKDIR)/refreshddr2/_behavioral.var $(WORKDIR)/writeddr2/_behavioral.var $(WORKDIR)/memcontmux/_behavioral.var $(WORKDIR)/memddr2/_behavioral.var $(WORKDIR)/retxbuffer/_behavioral.var 

comp: 

$(WORKDIR)/hy5ps121621f_pack/_hy5ps121621f_pack.var: ../../../memory/sim/components/hynix/HY5PS121621F_PACK.vhd
	$(VHDLC) ../../../memory/sim/components/hynix/HY5PS121621F_PACK.vhd

$(WORKDIR)/hy5ps121621f/_behavioral_model_hy5ps121621f.var: ../../../memory/sim/components/hynix/HY5PS121621F.vhd
	$(VHDLC) ../../../memory/sim/components/hynix/HY5PS121621F.vhd

$(WORKDIR)/retxbuffertest/_behavioral.var: retxbuffertest.vhd
	$(VHDLC) retxbuffertest.vhd

sim: $(WORKDIR)/hy5ps121621f_pack/_hy5ps121621f_pack.var $(WORKDIR)/hy5ps121621f/_behavioral_model_hy5ps121621f.var $(WORKDIR)/retxbuffertest/_behavioral.var 
runsim: all
	$(VHDLS) retxbuffertest


clean:
	rm -Rf $(WORKDIR)$

