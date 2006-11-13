VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/dqalign/_behavioral.var: ../../../vhdl/dqalign.vhd
	$(VHDLC) ../../../vhdl/dqalign.vhd

$(WORKDIR)/bootddr2/_behavioral.var: ../../../vhdl/dqalign.vhd ../../../vhdl/bootddr2.vhd
	$(VHDLC) ../../../vhdl/bootddr2.vhd

$(WORKDIR)/readddr2/_behavioral.var: ../../../vhdl/dqalign.vhd ../../../vhdl/bootddr2.vhd ../../../vhdl/readddr2.vhd
	$(VHDLC) ../../../vhdl/readddr2.vhd

$(WORKDIR)/refreshddr2/_behavioral.var: ../../../vhdl/dqalign.vhd ../../../vhdl/bootddr2.vhd ../../../vhdl/readddr2.vhd ../../../vhdl/refreshddr2.vhd
	$(VHDLC) ../../../vhdl/refreshddr2.vhd

$(WORKDIR)/writeddr2/_behavioral.var: ../../../vhdl/dqalign.vhd ../../../vhdl/bootddr2.vhd ../../../vhdl/readddr2.vhd ../../../vhdl/refreshddr2.vhd ../../../vhdl/writeddr2.vhd
	$(VHDLC) ../../../vhdl/writeddr2.vhd

$(WORKDIR)/memcontmux/_behavioral.var: ../../../vhdl/dqalign.vhd ../../../vhdl/bootddr2.vhd ../../../vhdl/readddr2.vhd ../../../vhdl/refreshddr2.vhd ../../../vhdl/writeddr2.vhd ../../../vhdl/memcontmux.vhd
	$(VHDLC) ../../../vhdl/memcontmux.vhd

$(WORKDIR)/memddr2/_behavioral.var: ../../../vhdl/dqalign.vhd ../../../vhdl/bootddr2.vhd ../../../vhdl/readddr2.vhd ../../../vhdl/refreshddr2.vhd ../../../vhdl/writeddr2.vhd ../../../vhdl/memcontmux.vhd ../../../vhdl/memddr2.vhd
	$(VHDLC) ../../../vhdl/memddr2.vhd

$(WORKDIR)/memtest/_behavioral.var: ../../../vhdl/dqalign.vhd ../../../vhdl/bootddr2.vhd ../../../vhdl/readddr2.vhd ../../../vhdl/refreshddr2.vhd ../../../vhdl/writeddr2.vhd ../../../vhdl/memcontmux.vhd ../../../vhdl/memddr2.vhd ../vhdl/memtest.vhd
	$(VHDLC) ../vhdl/memtest.vhd

hw: $(WORKDIR)/dqalign/_behavioral.var $(WORKDIR)/bootddr2/_behavioral.var $(WORKDIR)/readddr2/_behavioral.var $(WORKDIR)/refreshddr2/_behavioral.var $(WORKDIR)/writeddr2/_behavioral.var $(WORKDIR)/memcontmux/_behavioral.var $(WORKDIR)/memddr2/_behavioral.var $(WORKDIR)/memtest/_behavioral.var 

comp: 

$(WORKDIR)/hy5ps121621f_pack/prim.var: ../../../sim/components/hynix/HY5PS121621F_PACK.vhd
	$(VHDLC) ../../../sim/components/hynix/HY5PS121621F_PACK.vhd

$(WORKDIR)/hy5ps121621f/_behavioral_model_hy5ps121621f.var: ../../../sim/components/hynix/HY5PS121621F_PACK.vhd ../../../sim/components/hynix/HY5PS121621F.vhd
	$(VHDLC) ../../../sim/components/hynix/HY5PS121621F.vhd

$(WORKDIR)/memtesttest/_behavioral.var: ../../../sim/components/hynix/HY5PS121621F_PACK.vhd ../../../sim/components/hynix/HY5PS121621F.vhd memtesttest.vhd
	$(VHDLC) memtesttest.vhd

sim: $(WORKDIR)/hy5ps121621f_pack/prim.var $(WORKDIR)/hy5ps121621f/_behavioral_model_hy5ps121621f.var $(WORKDIR)/memtesttest/_behavioral.var 
runsim: all
	$(VHDLS) memtesttest


clean:
	rm -Rf $(WORKDIR)$

