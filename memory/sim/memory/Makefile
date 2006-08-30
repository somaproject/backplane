VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/dqalign/_behavioral.var: ../../vhdl/dqalign.vhd
	$(VHDLC) ../../vhdl/dqalign.vhd

$(WORKDIR)/bootddr2/_behavioral.var: ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd
	$(VHDLC) ../../vhdl/bootddr2.vhd

$(WORKDIR)/readddr2/_behavioral.var: ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd
	$(VHDLC) ../../vhdl/readddr2.vhd

$(WORKDIR)/refreshddr2/_behavioral.var: ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/refreshddr2.vhd
	$(VHDLC) ../../vhdl/refreshddr2.vhd

$(WORKDIR)/writeddr2/_behavioral.var: ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/refreshddr2.vhd ../../vhdl/writeddr2.vhd
	$(VHDLC) ../../vhdl/writeddr2.vhd

$(WORKDIR)/memcontmux/_behavioral.var: ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/refreshddr2.vhd ../../vhdl/writeddr2.vhd ../../vhdl/memcontmux.vhd
	$(VHDLC) ../../vhdl/memcontmux.vhd

$(WORKDIR)/memddr2/_behavioral.var: ../../vhdl/dqalign.vhd ../../vhdl/bootddr2.vhd ../../vhdl/readddr2.vhd ../../vhdl/refreshddr2.vhd ../../vhdl/writeddr2.vhd ../../vhdl/memcontmux.vhd ../../vhdl/memddr2.vhd
	$(VHDLC) ../../vhdl/memddr2.vhd

hw: $(WORKDIR)/dqalign/_behavioral.var $(WORKDIR)/bootddr2/_behavioral.var $(WORKDIR)/readddr2/_behavioral.var $(WORKDIR)/refreshddr2/_behavioral.var $(WORKDIR)/writeddr2/_behavioral.var $(WORKDIR)/memcontmux/_behavioral.var $(WORKDIR)/memddr2/_behavioral.var 

comp: 

$(WORKDIR)/hy5ps121621f_pack/prim.var: ../components/hynix/HY5PS121621F_PACK.vhd
	$(VHDLC) ../components/hynix/HY5PS121621F_PACK.vhd

$(WORKDIR)/hy5ps121621f/_behavioral_model_hy5ps121621f.var: ../components/hynix/HY5PS121621F_PACK.vhd ../components/hynix/HY5PS121621F.vhd
	$(VHDLC) ../components/hynix/HY5PS121621F.vhd

$(WORKDIR)/memddr2test/_behavioral.var: ../components/hynix/HY5PS121621F_PACK.vhd ../components/hynix/HY5PS121621F.vhd memddr2test.vhd
	$(VHDLC) memddr2test.vhd

sim: $(WORKDIR)/hy5ps121621f_pack/prim.var $(WORKDIR)/hy5ps121621f/_behavioral_model_hy5ps121621f.var $(WORKDIR)/memddr2test/_behavioral.var 
runsim: all
	$(VHDLS) memddr2test


clean:
	rm -Rf $(WORKDIR)$

