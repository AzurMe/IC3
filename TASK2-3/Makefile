# Makefile for Verilog simulation with Icarus Verilog and ModelSim
# Acknowledgements: Zhuolin Li, 2025

# Operating environment: powershell
# Usage:
#  make run WLF=top1
# This will generate top1.wlf

# ------------------------------
# User configuration
# ------------------------------
PROJ_DIR := D:/SOMEPROJECT/IC3Project/TASK2/TASK2-3
VSIM := D:/SOMEAPP/Modelsim/win64/modelsim.exe

# 默认 WLF 文件名
WLF ?= top
WLF_FILE := $(PROJ_DIR)/modelsim/$(WLF).wlf

# ------------------------------
# Targets
# ------------------------------

.PHONY: clean sim modelsim run

# 编译
compile:
	iverilog -o $(PROJ_DIR)/modelsim/tb_top.vvp \
	$(PROJ_DIR)/testbench/tb_top.v \
	$(PROJ_DIR)/rtl/top.v \
	$(PROJ_DIR)/rtl/counter.v \
	$(PROJ_DIR)/rtl/segment_static.v \
	$(PROJ_DIR)/rtl/key_debounce.v

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