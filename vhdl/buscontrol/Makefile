######################################################################
#
#
#   make PROJECTNAME: works through to the P&R
#   make bitfile: generate bitfile
#   make entity: tries to synth the entity
#
######################################################################
PROJECT = buscontrol

bitfile: $(PROJECT).bit

SOURCES = *.vhd 
OPTIMIZE = high
PART = xc3s1000-fg456-4

$(PROJECT): build/$(PROJECT).ncd

$(PROJECT).bit: build/$(PROJECT).bit
	rm -rf $(PROJECT).bit
	cp build/$(PROJECT).bit . 

# first stage : xst, produces ngc

build/$(PROJECT).ngc: $(SOURCES) $(PROJECT).xst $(PROJECT).prj
	xst -ifn $(PROJECT).xst

%.syn : %.vhd
	sed "s/-top $(PROJECT)/-top $(subst .vhd,,$<)/" $(PROJECT).xst > .$<.xst
	xst -ifn .$<.xst

#second stage : ngdbuild, produces .ngd
build/$(PROJECT).ngd: build/$(PROJECT).ngc $(PROJECT).ucf 
	ngdbuild -p $(PART) -uc $(PROJECT).ucf -dd build $(PROJECT).ngc build/$(PROJECT).ngd


# third stage: map: produces pcf, map.ncd

build/$(PROJECT).pcf: build/$(PROJECT).ngd
	map -p $(PART) -ol $(OPTIMIZE) -timing -cm speed  -o build/map.ncd build/$(PROJECT).ngd build/$(PROJECT).pcf

build/$(PROJECT).ncd: build/$(PROJECT).pcf
	par -w -pl $(OPTIMIZE) -rl $(OPTIMIZE)  build/map.ncd build/$(PROJECT).ncd build/$(PROJECT).pcf

build/$(PROJECT).bit: build/$(PROJECT).pcf build/$(PROJECT).ncd
	bitgen -w build/$(PROJECT).ncd build/$(PROJECT).bit build/$(PROJECT).pcf
# timing reports
timing: build/$(PROJECT).twr
	less build/$(PROJECT).twr


build/$(PROJECT).twr: build/$(PROJECT).ncd build/$(PROJECT).pcf
	trce -intstyle ise -e 3 -l 3 -s 4 -xml $(PROJECT) build/$(PROJECT).ncd -o build/$(PROJECT).twr build/$(PROJECT).pcf
