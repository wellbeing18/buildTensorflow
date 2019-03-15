all: main.cpp
	g++ -std=c++11 -I . main.cpp -o build/main.o
	./build/main.o
debug: main.cpp
	g++ -g -std=c++11 -I . main.cpp -o build/main.o
	./build/main.o
test: tests/test.cpp
	g++ -std=c++11 -I . tests/test.cpp -lgtest -lgtest_main -pthread -o build/test.o
	./build/test.o
gpuTest: gpu/cudaOps.cu
	nvcc -std=c++14 -I . gpu/cudaOps.cu -o build/cuda.o
	./build/cuda.o
	
