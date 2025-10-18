# Makefile for Verilog simulation with Icarus Verilog and ModelSim
# Acknowledgements: Zhuolin Li, 2025

# Operating environment: powershell
# Usage:
#  make run WLF=top1
# This will generate top1.wlf

# ------------------------------
# User configuration
# ------------------------------
PROJ_DIR := D:/SOMEPROJECT/IC3Project/TASK2/TASK2-4
VSIM := D:/SOMEAPP/Modelsim/win64/modelsim.exe
RTL_DIR := $(PROJ_DIR)/rtl
FILELIST := $(PROJ_DIR)/file.list

# 默认 WLF 文件名
WLF ?= top
WLF_FILE := $(PROJ_DIR)/modelsim/$(WLF).wlf

# ------------------------------
# Targets
# ------------------------------

.PHONY: clean sim modelsim run

# 自动查找所有.v文件
RTL_SOURCES := $(wildcard $(RTL_DIR)/*.v)
TESTBENCH_SOURCES := $(wildcard $(PROJ_DIR)/testbench/*top.v)

filelist:
	echo # Auto-generated file list > $(FILELIST)
	echo # RTL files: >> $(FILELIST)
	$(foreach file,$(RTL_SOURCES),echo $(file) >> $(FILELIST) &)
	echo # Testbench files: >> $(FILELIST)
	$(foreach file,$(TESTBENCH_SOURCES),echo $(file) >> $(FILELIST) &)
	echo # End of list >> $(FILELIST)
	@echo "file.list is generated at $(FILELIST)"

# 编译
compile:
	iverilog -o $(PROJ_DIR)/modelsim/tb_top.vvp \
	$(RTL_SOURCES) \
	$(TESTBENCH_SOURCES)

# 运行仿真
sim:
	cd $(PROJ_DIR)/modelsim && vvp tb_top.vvp

# VCD 转 WLF
vcd2wlf:
	cd $(PROJ_DIR)/modelsim && vcd2wlf tb_top.vcd $(WLF).wlf

# 调用 ModelSim
modelsim:
	@echo "Starting ModelSim with file: $(WLF_FILE)"
	@powershell -Command "if (Test-Path '$(WLF_FILE)') { Write-Host 'WLF file exists' } else { Write-Host 'WLF file not found: $(WLF_FILE)' }"
	start "" "$(VSIM)" -view "$(WLF_FILE)"

# 一键执行：编译 -> 仿真 -> VCD转WLF -> 打开 Modelsim
run: compile sim vcd2wlf modelsim

# 清理生成文件
clean:
	-powershell -Command "Remove-Item -Path '$(PROJ_DIR)/modelsim/tb_segment_static.vvp' -Force -ErrorAction SilentlyContinue"
	-powershell -Command "Remove-Item -Path '$(PROJ_DIR)/modelsim/tb_segment_static.vcd' -Force -ErrorAction SilentlyContinue"
	-powershell -Command "Remove-Item -Path '$(PROJ_DIR)/modelsim/$(WLF).wlf' -Force -ErrorAction SilentlyContinue"