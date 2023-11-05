ARCH := $(shell uname -m)
DUMPWAVE     := 1
CORE  := TEST_A100
BUILD_DIR := ${PWD}/build
VSRC_DIR     := ${PWD}/${CORE}/rtl
VTB_DIR      := ${PWD}/${CORE}/tb
JTAG_DIR 	 := ${PWD}/${CORE}/jtag_vpi


#To-ADD: to add the simulatoin tool options

VERILATOR_BUILD_DIR := ${BUILD_DIR}
SIM_OPTIONS   := --Mdir ${VERILATOR_BUILD_DIR} 
SIM_OPTIONS   += --cc +incdir+${VSRC_DIR}/bus  -CFLAGS -I${VSRC_DIR}/bus +incdir+${VSRC_DIR} -CFLAGS -I${VSRC_DIR}
SIM_OPTIONS   += +incdir+${VSRC_DIR}/perips/apb_i2c/ -CFLAGS -I${VSRC_DIR}/perips/apb_i2c/
SIM_OPTIONS   += --exe --trace --trace-structs --trace-params --trace-max-array 1024
SIM_OPTIONS   += -CFLAGS "-Wall -DTOPLEVEL_NAME=ahb_top -g -O0" -LDFLAGS "-pthread -lutil -lelf"
SIM_OPTIONS   +=  -Wno-PINCONNECTEMPTY -Wno-fatal -Wno-WIDTH -Wno-CASEINCOMPLETE -Wno-UNOPTFLAT

SIM_OPTIONS_BACK := --top-module ahb_top --exe
SIM_OPTIONS_BACK   += ${SIM_OPTIONS_COMMON}

VERILATOR_CC_FILE := ${VTB_DIR}/tb_top.cc

RTL_V_FILES		:= $(wildcard ${VSRC_DIR}/*/*.v ${VSRC_DIR}/*/*/*.v ${VSRC_DIR}/*/*.sv ${VSRC_DIR}/*/*/*.sv)
TB_V_FILES		:= $(wildcard ${VTB_DIR}/*.v wildcard ${VTB_DIR}/*.sv)


SIM_TOOL_EXEC  := verilator
E203_EXEC_DIR := ${BUILD_DIR}/exec
ifeq ($(ARCH),x86_64)
VERILATOR_COMPILE_CMD := make -f Vahb_top.mk -C ${BUILD_DIR} -j$(nproc)
else ifeq ($(ARCH),aarch64)
VERILATOR_COMPILE_CMD := make -f Vahb_top.mk -C ${BUILD_DIR} -j4
endif
SIM_EXEC := ${E203_EXEC_DIR}/Vahb_top
SIM_WAV_FILE := ${E203_EXEC_DIR}/Vahb_top.vcd
SIM_CMD := ${SIM_EXEC}  -t


EXEC_POST_PROC := @cp -f ${BUILD_DIR}/Vahb_top ${E203_EXEC_DIR}


WAV_TOOL := gtkwave

all: run

compile.flg: ${RTL_V_FILES} ${TB_V_FILES}
	@-rm -rf compile.flg
	@rm -rf ${BUILD_DIR}
	@mkdir -p ${E203_EXEC_DIR}
	${SIM_TOOL_EXEC} ${SIM_OPTIONS}  ${RTL_V_FILES} ${TB_V_FILES} ${VERILATOR_CC_FILE} ${SIM_OPTIONS_BACK}
	${VERILATOR_COMPILE_CMD}
	${EXEC_POST_PROC}
	@touch compile.flg

compile: compile.flg

wave: run
	${WAV_TOOL} ${WAV_OPTIONS} ${WAV_INC} ${WAV_RTL} ${SIM_WAV_FILE}  &

run: compile
	@cd ${E203_EXEC_DIR};${SIM_CMD}

clean:
	rm -rf ${BUILD_DIR}
	rm -rf compile.flg
.PHONY: run 

