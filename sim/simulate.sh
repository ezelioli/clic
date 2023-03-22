VER=2021.3
QUESTA=questa-${VER}
VSIM_OPT=-c
VSIM_POST="-do exit"

GUI=0

if [[ $# -gt 1 ]]; then
        echo "ERROR: too many parameters (0|1 expected)"
        exit 1
fi

if [[ $# -eq 1 ]]; then
        case $1 in
                -g|--gui)
                        GUI=1
                        ;;
                *)
                        echo "ERROR: unexpected parameter \'$1\'"
                        exit 2
                        ;;
        esac
fi

if [[ ${GUI} -ne 0 ]]; then
	VSIM_OPT=""
        VSIM_POST=""
fi

rm -rf ./traces/*

mkdir -p ./traces

${QUESTA} vsim ${VSIM_OPT} \
	-do 'source ./sim/tcl/runsim.tcl' \
	-do 'source ./sim/tcl/waves.tcl' \
	-do 'run -a' ${VSIM_POST}

rm -rf vsim.wlf transcript

exit 0