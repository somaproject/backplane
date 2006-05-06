######################################################################
#
#
#   make PROJECTNAME: works through to the P&R
#   make bitfile: generate bitfile
#   make entity: tries to synth the entity
#   targets:
#   make synth: perform synthesis
#   make tran : translation
#   make map : mapping
#   make par : place-and-route
#   make synthsim: post-synthesis model
#   make fitsim: post-fit simulation model
#   make multipar : multiple attemt place and route
######################################################################
PROJECT = boot

bitfile: $(PROJECT).jed

# process flow for a cpld: 
#   (.vhd,.ver)-->[XST]-->(.ngc,.ucf)-->[NGDBUILD]-->(.ngd)-->[CPLDFIT]-->(.vm6)--> -->[HPREP6]-->(.jed)-->[IMPACT]-->(.svf)


SOURCES = *.vhd
OPTIMIZE = high
PART = XC2C64A-5-VQ44
SPEED = 4

$(PROJECT): build/$(PROJECT).ncd

#$(PROJECT).jed: build/$(PROJECT).jed
#rm -rf $(PROJECT).jed
#cp build/$(PROJECT).jed . 

$(PROJECT).rbt: build/$(PROJECT).rbt
	rm -rf $(PROJECT).rbt
	cp build/$(PROJECT).rbt . 

# coregen files:
%.edn : %.xco
	coregen -b $<

# first stage : xst, produces ngc
synth: build/$(PROJECT).ngc

build/$(PROJECT).ngc: $(SOURCES) $(PROJECT).xst $(PROJECT).prj
	mkdir -p build
	xst -ifn $(PROJECT).xst
	mv $(PROJECT).ngc build/

%.syn : %.vhd
	sed "s/-top $(PROJECT)/-top $(subst .vhd,,$<)/" $(PROJECT).xst > .$<.xst
	xst -ifn .$<.xst

#second stage : ngdbuild, produces .ngd
trans: build/$(PROJECT).ngd

build/$(PROJECT).ngd: build/$(PROJECT).ngc $(PROJECT).ucf 
	ngdbuild -p $(PART) -uc $(PROJECT).ucf -dd build build/$(PROJECT).ngc build/$(PROJECT).ngd


# third CPLD stage, fit:
$(PROJECT).vm6: build/$(PROJECT).ngd
	cpldfit -p $(PART) -ofmt vhdl -optimize density -loc on -slew fast -init low -inputs 32 -inreg on -blkfanin 38  -unused keeper -terminate keeper -iostd LVTTL build/$(PROJECT).ngd -exhaust

$(PROJECT).jed: $(PROJECT).vm6
	hprep6 -s IEEE1149   -i $(PROJECT).vm6


# timing reports
timing: build/$(PROJECT).twr
	less build/$(PROJECT).twr


build/$(PROJECT).twr: build/$(PROJECT).ncd build/$(PROJECT).pcf
	trce -intstyle ise -e 3 -l 3 -s $(SPEED) -xml $(PROJECT) build/$(PROJECT).ncd -o build/$(PROJECT).twr build/$(PROJECT).pcf


# simulations
fitsim: build/$(PROJECT)_timesim.vhd
build/$(PROJECT)_timesim.vhd: build/$(PROJECT).ngd
	netgen -intstyle ise -rpw 100 -ar Structure -tm $(PROJECT) -w -dir build -ofmt vhdl -sim build/$(PROJECT).ngd $(PROJECT)_timesim.vhd


# cleanup
clean:
	rm -Rf xst build
