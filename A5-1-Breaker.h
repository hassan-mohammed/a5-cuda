#pragma once

void RunTestCases();

void DeviceProperties();

void checkCudaErrors(cudaError_t err);
void AllocateGPUMemory(int*& d_outStream, uint8_t*& d_AssumedBitstruthTableZonotope, uint8_t* AssumedBitstruthTableZonotope,
    uint8_t*& d_threeBitsTruthTableZonotope, int*& d_validGuessConBag, int validGuessVectorSize, int* validGuessVector);
void LaunchFindValidCompinationsKernel(uint8_t* d_AssumedBitstruthTableZonotope, int* d_outStream);

void FindValidCompinationsCPU(std::vector<int*>& validGuessConBag);
//void LaunchFindA5KeyKernel(std::vector<int*>& validGuessConBag);
//void LaunchFindValidCompinationsKernel(std::vector<int*>& validGuessConBag);
//

void Initialization();

void GenerateA5Output();
