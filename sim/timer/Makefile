VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/somabackplane/_body.var: ../../vhdl/somabackplane.vhd
	$(VHDLC) ../../vhdl/somabackplane.vhd

$(WORKDIR)/timer/_behavioral.var: ../../vhdl/timer.vhd
	$(VHDLC) ../../vhdl/timer.vhd

hw: $(WORKDIR)/somabackplane/_body.var $(WORKDIR)/timer/_behavioral.var 

comp: 

$(WORKDIR)/timertest/_behavioral.var: timertest.vhd
	$(VHDLC) timertest.vhd

sim: $(WORKDIR)/timertest/_behavioral.var 
runsim: all
	$(VHDLS) timertest


clean:
	rm -Rf $(WORKDIR)$

