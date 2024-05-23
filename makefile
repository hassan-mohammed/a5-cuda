# Makefile

# Compiler
NVCC = nvcc

# Target executable
TARGET = a5breaker

# Source files
SRCS = kernel.cu A5-1-Breaker.cu A5_1.cpp Helper.cpp ReverseQueue.cu A5Breaker_LogicalZonotope.cu TestCases.cpp A5LogicalZonotopeQueue.cu LightLogicalZonotope.cpp ZonotopeOperations.cpp

# Compiler flags
NVCCFLAGS = -std=c++11

all: $(TARGET)

$(TARGET): $(SRCS)
	$(NVCC) $(NVCCFLAGS) -o $(TARGET) $(SRCS)

clean:
	rm -f $(TARGET)
