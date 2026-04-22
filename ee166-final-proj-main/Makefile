SYNOPSYS = licenses/synopsys
CADENCE = licenses/cadence

MODULE = . /usr/share/Modules/init/sh; module use /usr/cots/modulefiles; module load $(SYNOPSYS) $(CADENCE)

GENUS   = tools/genus/21.18
INNOVUS = tools/innovus/21.18

XCELIUM   = tools/xcelium/23.03
VERISIUM  = tools/verisium/24.09
#####################################
#          INVOKE TOOLS             #
#####################################

#COMPILE = cd work; $(MODULE) $(DC); time dc_shell-xg-t -64bit
COMPILE = cd work; $(MODULE) $(GENUS); time genus
PNR 	= cd work; $(MODULE) $(INNOVUS); time innovus
XRUN    = cd work; $(MODULE) $(XCELIUM) $(VERISIUM); time xrun
#####################################
#              SETUP                #
#####################################
RUNDIR  = $(PWD)
LOGS    = $(RUNDIR)/logs
SCRIPTS = $(RUNDIR)/scripts
DATE    = "`date '+%m_%d_%H_%M'`"

#####################################
#              FRONT                #
#####################################
tell_date:
	echo $(DATE)

sim: dirs
	$(XRUN) -sv -gui -64bit -lwdgen -access +rwc -verisium +incdir+../rtl -top tb -f ../rtl/lab1.vc -l ./simulation.log


compile: dirs
	$(COMPILE) -files $(SCRIPTS)/compile.tcl -log compile | tee $(LOGS)/compile.log

#####################################
#         CREATE DIRECTORIES        #
#####################################
dirs:
	@mkdir -p work/
	@mkdir -p $(LOGS)
	@mkdir -p data/
	@mkdir -p reports/

clean:
	@echo "Cleaning example directory ..."
	@/bin/rm -rf work/.[a-zA-Z]*
	@/bin/rm -rf work*
	@/bin/rm -rf $(LOGS)
	@/bin/rm -rf data
	@/bin/rm -rf reports
genus:
	$(COMPILE)

