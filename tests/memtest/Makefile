VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/memtest/_behavioral.var: memtest.vhd
	$(VHDLC) memtest.vhd

hw: $(WORKDIR)/memtest/_behavioral.var 

comp: 
