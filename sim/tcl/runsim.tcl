set LIB sim/work
set DEBUG ON
set COVERAGE OFF

if {$DEBUG == "ON"} {
    set VOPT_ARG "+acc"
    echo $VOPT_ARG
    set DB_SW "-debugdb"
} else {
    set DB_SW ""
}

if {$COVERAGE == "ON"} {
    set COV_SW -coverage
} else {
    set COV_SW ""
}

vsim -lib $LIB -c clic_tb -t 1ps -voptargs=+acc -pedanticerrors 
