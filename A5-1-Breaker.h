#pragma once

void RunTestCases();

void DeviceProperties();


void AllocateGPUMemory(int*& d_outStream, LightLogicalZonotope*& d_AssumedBitstruthTableZonotope, LightLogicalZonotope* AssumedBitstruthTableZonotope,
    LightLogicalZonotope*& d_threeBitsTruthTableZonotope, int*& d_validGuessConBag, int validGuessVectorSize, int* validGuessVector);
void LaunchFindValidCompinationsKernel(LightLogicalZonotope* d_AssumedBitstruthTableZonotope, int* d_outStream);

void FindValidCompinationsCPU(std::vector<int*>& validGuessConBag);
//void LaunchFindA5KeyKernel(std::vector<int*>& validGuessConBag);
//void LaunchFindValidCompinationsKernel(std::vector<int*>& validGuessConBag);
//

void Initialization();

void GenerateA5Output();
