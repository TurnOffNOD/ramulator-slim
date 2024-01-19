SRCDIR := src
OBJDIR := obj
MAIN := $(SRCDIR)/Main.cpp
SRCS := $(filter-out $(MAIN) $(SRCDIR)/Gem5Wrapper.cpp, $(wildcard $(SRCDIR)/*.cpp))
OBJS := $(patsubst $(SRCDIR)/%.cpp, $(OBJDIR)/%.o, $(SRCS))

DRAMPowerIncludeDIR := ../dramPower-my/src/DRAMPower
nlohmann_jsonIncludeDIR := ../dramPower-my/lib/nlohmann_json/include
DRAMPowerLIBDIR := ../dramPower-my/build/lib
JSONparseLIBDIR := ../dramPower-my/lib/nlohmann_json
dramPowerOBJS := $(shell find ../dramPower-my/build/src/DRAMPower/CMakeFiles/DRAMPower.dir/DRAMPower -name '*.o')


# Ramulator currently supports g++ 5.1+ or clang++ 3.4+.  It will NOT work with
#   g++ 4.x due to an internal compiler error when processing lambda functions.
CXX := clang++
#CXX := g++
# CXX := g++-5
CXXFLAGS := -O3 -std=c++17 -g -Wall -I$(DRAMPowerIncludeDIR) -I$(nlohmann_jsonIncludeDIR) -L$(DRAMPowerLIBDIR) -lDRAMPower
.PHONY: all clean depend

all: depend ramulator
#	$(info "in target all")
	@echo "\033[33;46;1m in target all \033[0m"

clean:
	rm -f ramulator
	rm -rf $(OBJDIR)

depend: $(OBJDIR)/.depend
#	$(info "in target depend")
	@echo "\033[33;46;1m in target depend \033[0m"


$(OBJDIR)/.depend: $(SRCS)
#	$(info "in target OBJDIR/.depend")
	@echo "\033[33;46;1m in target OBJDIR/.depend \033[0m"
	@mkdir -p $(OBJDIR)
	@rm -f $(OBJDIR)/.depend
	@$(foreach SRC, $(SRCS), $(CXX) $(CXXFLAGS) -DRAMULATOR -MM -MT $(patsubst $(SRCDIR)/%.cpp, $(OBJDIR)/%.o, $(SRC)) $(SRC) >> $(OBJDIR)/.depend ;)

ifneq ($(MAKECMDGOALS),clean)
-include $(OBJDIR)/.depend
endif


ramulator: $(MAIN) $(OBJS) $(SRCDIR)/*.h | depend
#	$(info "in target ramulator")
	@echo "\033[33;46;1m in target ramulator \033[0m"
	$(CXX) $(CXXFLAGS) -DRAMULATOR -o $@ $(MAIN) $(OBJS) $(dramPowerOBJS)

libramulator.a: $(OBJS) $(OBJDIR)/Gem5Wrapper.o
	libtool -static -o $@ $(OBJS) $(OBJDIR)/Gem5Wrapper.o

$(OBJS): | $(OBJDIR)

$(OBJDIR): 
	@mkdir -p $@

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	$(CXX) $(CXXFLAGS) -DRAMULATOR -c -o $@ $<
