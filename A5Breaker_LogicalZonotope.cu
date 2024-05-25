
#include <cmath>
#include <vector>
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <thread>
#include "ReverseQueue.cu"
#include "A5LogicalZonotopeQueue.cu"
#include <ctime>
#include "device_launch_parameters.h"
#include <cuda_runtime.h>

#pragma once

//__device__  int* d_outStream = NULL;
//__device__  int d_count = 0;

__device__   __constant__ int d_noAssumedBits = 5;


static __device__  uint8_t* GenerateLogicalZonotopeRegisterDevice(int length) {

    uint8_t* reg = new uint8_t[length];

    for (int i = 0; i < length; i++) {
        reg[i] = 2;
    }

    return reg;
}

static  __device__  uint8_t* GenerateLogicalZonotopeRegisterDevice(uint8_t* reg, int length) {
    for (int i = 0; i < length; i++) {
        reg[i] = 2;
    }

    return reg;
}

static  __device__  uint8_t* GenerateLogicalZonotopeRegisterDevice(uint8_t* reg, int length, uint8_t* point) {
    for (int i = 0; i < length - d_noAssumedBits; i++) {
        reg[i] = *point;
    }

    return reg;
}
static __device__ void FillLastNBitsWithRowDevice(uint8_t* reg, const int regLength, const uint8_t* truthTableZonotope, int rowNo, int noBits) {
    int startIndex = regLength - noBits;

    for (int i = 0; i < noBits - d_noAssumedBits; i++) {
        reg[startIndex + i] = truthTableZonotope[rowNo * noBits + i];  //TODO here we assume that we just want to point to this point
    }
}

static __device__ void PrintRegistersDevice(const LightLogicalZonotope* RA, const LightLogicalZonotope* RB, const LightLogicalZonotope* RC) {
    // Print RA
    printf("RA = {             ");
    for (int i = 0; i < RAlength; ++i) {
        if (RA[i].Generator == 0) {
            printf("%d, ", RA[i].Point);
        }
        else {
            printf("Z, ");
        }
    }
    printf("}\n");

    // Print RB
    printf("RB = {    ");
    for (int i = 0; i < RBlength; ++i) {
        if (RB[i].Generator == 0) {
            printf("%d, ", RB[i].Point);
        }
        else {
            printf("Z, ");
        }
    }
    printf("}\n");

    // Print RC
    printf("RC = { ");
    for (int i = 0; i < RClength; ++i) {
        if (RC[i].Generator == 0) {
            printf("%d, ", RC[i].Point);
        }
        else {
            printf("Z, ");
        }
    }
    printf("}\n");
}
static __device__  void PrintRegistersDevice(const uint8_t  RA[], const uint8_t  RB[], const uint8_t  RC[], int count = 0) {
    // Print RA
    printf("RA = {             ");
    for (int i = 0; i < RAlength; ++i) {
            printf("%d, ", RA[i]);
    }
    printf("}\n");

    // Print RB
    printf("RB = {    ");
    for (int i = 0; i < RBlength; ++i) {
            printf("%d, ", RB[i]);
    }
    printf("}\n");

    // Print RC
    printf("RC = { ");
    for (int i = 0; i < RClength; ++i) {
            printf("%d, ", RC[i]);
    }
    printf("}\n");
}



//static uint8_t* RA = Helper::GenerateLogicalZonotopeRegister(RAlength);
//static uint8_t* RB = Helper::GenerateLogicalZonotopeRegister(RBlength);
//static uint8_t* RC = Helper::GenerateLogicalZonotopeRegister(RClength);



//TODO this function need some cleaning of varaibles and sorting of the logic



//static int deepBitsTableLength;
//static uint8_t* threeBitsTruthTableZonotope;
//static uint8_t* sixBitsTruthTableZonotope;
//static uint8_t* deepTruthTableZonotope;
//static int RAlastZTind, RBlastZTind, RClastZTind;
//static uint8_t tempPoint = uint8_t{0, 1}; 
//static int threeBitsTableLength = 8;
//static int totalAssumedBits;
//
//static void InitializeStaticMembers();
//static  bool A5RFBZT_12_DeepModeLoop_A5Loop(uint8_t* RA, uint8_t* RB, uint8_t* RC, const std::string& indexText);
//static void A5FullKey(uint8_t* RAcurr, uint8_t* RBcurr, uint8_t* RCcurr, int initialRClastZTind, std::string indexText);
//static void finalStep(uint8_t* RAcurr, uint8_t* RBcurr, uint8_t* RCcurr, int initialRClastZTind);
//
//
//
//
//static void InitializeStaticMembers() {
//        RAlastZTind = RAlength - noAssumedBits - 1;
//        RBlastZTind = RAlength - noAssumedBits + 2;
//        RClastZTind = RAlength - noAssumedBits + 3;
//        deepBitsTableLength = static_cast<int>(std::pow(2, deepNoAssumedBits * 3));
//        threeBitsTruthTableZonotope = Helper::GetTruthTableZonotope(1 * 3);
//        sixBitsTruthTableZonotope = Helper::GetTruthTableZonotope(2 * 3);
//        deepTruthTableZonotope = Helper::GetTruthTableZonotope(deepNoAssumedBits * 3);
//
//        totalAssumedBits = deepNoAssumedBits * 3;
//    }
//
//    //for (int mainIndex = 0; mainIndex < mainIndexLength; ++mainIndex) {
//       //    // Ensure we don't create more threads than allowed
//       //    if (threads.size() >= maxThreads) {
//       //        // Join threads before creating new ones
//       //        for (auto& thread : threads) {
//       //            thread.join();
//       //        }
//       //        threads.clear();
//       //    }
//
//       //    threads.emplace_back([mainIndex, RA, RB, RC, indexText]() {
//
//    static  bool A5RFBZT_12_DeepModeLoop_A5Loop(uint8_t* RA, uint8_t* RB, uint8_t* RC, const std::string& indexText) {
//        const int mainIndexLength = 64;  // Assuming sixBitsTableLength is 64
//
//        // Set up parallel options
//        int maxThreads = std::thread::hardware_concurrency() / 4;
//        std::vector<std::thread> threads;
//
//       // int mainIndex = 8;
//
//        //// Perform parallel loop
//        //for (int mainIndex = 0; mainIndex < mainIndexLength; ++mainIndex) {
//        //    threads.emplace_back([mainIndex, RA, RB, RC, indexText]() {
//
//        // Use TBB for parallel loop
//        tbb::parallel_for(0, mainIndexLength, [&](int mainIndex) {
//       // for (int mainIndex = 0; mainIndex < mainIndexLength; ++mainIndex) {
//
//            std::string outputString;
//            bool isValid = false;
//            bool isKeyFound = false;
//
//            // Create temporary copies of RA, RB, RC
//            uint8_t* tempRA = new uint8_t[RAlength];
//            uint8_t* tempRB = new uint8_t[RBlength];
//            uint8_t* tempRC = new uint8_t[RClength];
//
//            // Copy values from RA, RB, RC to temporary arrays
//            std::copy(RA, RA + RAlength, tempRA);
//            std::copy(RB, RB + RBlength, tempRB);
//            std::copy(RC, RC + RClength, tempRC);
//
//
//            tempRA[RAlastZTind] = sixBitsTruthTableZonotope[mainIndex * 6 + 0];//[0];
//            tempRB[RBlastZTind] = sixBitsTruthTableZonotope[mainIndex * 6 + 1];//[1];
//            tempRC[RClastZTind] = sixBitsTruthTableZonotope[mainIndex * 6 + 2];//[2];
//
//            tempRA[RAlastZTind - 1] = sixBitsTruthTableZonotope[mainIndex * 6 + 3];//[3];
//            tempRB[RBlastZTind - 1] = sixBitsTruthTableZonotope[mainIndex * 6 + 4];//[4];
//            tempRC[RClastZTind - 1] = sixBitsTruthTableZonotope[mainIndex * 6 + 5];//[5];
//            if (isExactPoly)
//            {
//               // A5PolyLogicalZonotope A5PolyZonotope(tempRA, tempRB, tempRC);
//               // isValid = A5PolyZonotope.IsValidKey();
//            }
//            else
//            {
//                A5LogicalZonotopeQueue A5Zonotope(tempRA, tempRB, tempRC);
//                isValid = A5Zonotope.IsValidKey('A');
//                if (!isValid) isValid = A5Zonotope.IsValidKey('B');
//                if (!isValid) isValid = A5Zonotope.IsValidKey('C');
//                if (!isValid) isValid = A5Zonotope.IsValidKey('D');
//
//            }
//
//
//            if (isValid) {
//                outputString = "  [Deep Mode] index [" + std::to_string(mainIndex) + "] for [Main Thread] " + indexText + " is valid looking inside @ " + Helper::GetCurrentTime();
//                std::cout << outputString << std::endl;
//                A5FullKey(tempRA, tempRB, tempRC, RClastZTind - 2, indexText + " - M = " + std::to_string(mainIndex));
//                /* outputString = "  [Deep Mode] index [" + std::to_string(mainIndex) + "] for [Main Thread] " + indexText + " is FINISHED @ " + Helper::GetCurrentTime();
//                 std::cout << outputString << std::endl;*/
//            }
//            else {
//                outputString = "  [Deep Mode] index [" + std::to_string(mainIndex) + "] for [Main Thread] " + indexText + " is NOT VALID @ " + Helper::GetCurrentTime();
//                std::cout << outputString << std::endl;
//            }
//            delete[] tempRA;
//            delete[] tempRB;
//            delete[] tempRC;
//        });
//
// 
//        return false;
//    }
//
//    static void A5FullKey(uint8_t* RAcurr, uint8_t* RBcurr, uint8_t* RCcurr, int initialRClastZTind, std::string indexText) {
//        //A5PolyLogicalZonotope A5PolyZonotope(RAcurr, RBcurr, RCcurr);
//        A5LogicalZonotopeQueue A5Zonotope(RAcurr, RBcurr, RCcurr);
//        uint8_t* tempRAKey = new uint8_t[RAlength];
//        uint8_t* tempRBKey = new uint8_t[RBlength];
//        uint8_t* tempRCKey = new uint8_t[RClength];
//
//        int relativeIndex = initialRClastZTind;
//        int lastIndex = relativeIndex - noSegmants * deepNoAssumedBits;
//
//       // ReverseQueue segIndexQueue(RClength);
//        ReverseQueue segIndexQueue = initializeReverseQueue(RClength);
//
//
//        int index = 0;
//        bool isValid;
//        bool clkCondArray[4] = { false, false, false, false };
//        int deepRelativeIndex = relativeIndex - deepNoAssumedBits;
//        int deepInitialRClastZTind = deepRelativeIndex;
//        std::string outputString;
//
//        while (true) {
//            while (index < deepBitsTableLength) {
//                Helper::FillNBitsWithRow(RAcurr, deepRelativeIndex - 3, &deepTruthTableZonotope[index * totalAssumedBits], 0, deepNoAssumedBits);
//                Helper::FillNBitsWithRow(RBcurr, deepRelativeIndex, &deepTruthTableZonotope[index * totalAssumedBits], deepNoAssumedBits, deepNoAssumedBits);
//                Helper::FillNBitsWithRow(RCcurr, deepRelativeIndex + 1, &deepTruthTableZonotope[index * totalAssumedBits], deepNoAssumedBits * 2, deepNoAssumedBits);
//
//
//                isValid = false;
//                // MajorityFunction and IsValidKey functions are not provided; replace them with actual implementations.
//                if (isExactPoly)
//                {
//                   // isValid = A5PolyZonotope.IsValidKey();
//                }
//                else
//                {
//
//                    A5LogicalZonotopeQueue::MajorityFunction(RAcurr[8], RBcurr[10], RCcurr[10], clkCondArray);
//                    if (clkCondArray[0])
//                        isValid = A5Zonotope.IsValidKey('A');
//                    if (clkCondArray[1] && !isValid)
//                        isValid = A5Zonotope.IsValidKey('B');
//                    if (clkCondArray[2] && !isValid)
//                        isValid = A5Zonotope.IsValidKey('C');
//                    if (clkCondArray[3] && !isValid)
//                        isValid = A5Zonotope.IsValidKey('D');
//                }
//
//                if (isValid) {
//                    if (deepRelativeIndex == lastIndex) {
//
//                        std::copy(RAcurr, RAcurr + RAlength, tempRAKey);
//                        std::copy(RBcurr, RBcurr + RBlength, tempRBKey);
//                        std::copy(RCcurr, RCcurr + RClength, tempRCKey);
//
//                        //// Replace with actual copying logic
//                        //for (int i = 0; i < RAlength; ++i) {
//                        //    tempRAKey[i] = RAcurr[i];
//                        //}
//                        //for (int i = 0; i < RBlength; ++i) {
//                        //    tempRBKey[i] = RBcurr[i];
//                        //}
//                        //for (int i = 0; i < RClength; ++i) {
//                        //    tempRCKey[i] = RCcurr[i];
//                        //}
//
//                        finalStep(tempRAKey, tempRBKey, tempRCKey, lastIndex);
//                        /*
//                           outputString = " [Main Thread] " + indexText + " index so far is " + std::to_string(index) + " @ " + Helper::GetCurrentTime();
//                           std::cout << outputString << std::endl;*/
//
//                        index++;
//                        continue;
//                    }
//                    deepRelativeIndex = deepRelativeIndex - deepNoAssumedBits;
//                   // segIndexQueue.Enqueue(index);
//                    Enqueue(segIndexQueue, index);
//
//                    index = 0;
//                }
//                else {
//                    index++;
//                }
//            }
//
//            if (QueueSize(segIndexQueue) != 0) {
//                if (deepRelativeIndex < deepInitialRClastZTind) {
//                    for (int i = 1; i < deepNoAssumedBits + 1; i++) {
//                        RCcurr[deepRelativeIndex + i] = tempPoint;
//                        RBcurr[deepRelativeIndex - 1 + i] = tempPoint;
//                        RAcurr[deepRelativeIndex - 4 + i] = tempPoint;
//                    }
//
//                   // index = segIndexQueue.Dequeue() + 1;
//                    index = Dequeue(segIndexQueue) + 1;
//
//                    deepRelativeIndex = deepRelativeIndex + deepNoAssumedBits;
//                }
//            }
//            else {
//                outputString = " [Main Thread] " + indexText + " --- FINISHED DEEP @ " + Helper::GetCurrentTime();
//
//                std::cout << " [Main Thread] " << indexText << " --- FINISHED DEEP @ " << Helper::GetCurrentTime() << std::endl;
//                delete[] tempRAKey;
//                delete[] tempRBKey;
//                delete[] tempRCKey;
//                return;
//            }
//        }
//    }
//   
//    static void finalStep(uint8_t* RAcurr, uint8_t* RBcurr, uint8_t* RCcurr, int initialRClastZTind)
//    {
//        std::string outputString;
//        A5LogicalZonotopeQueue A5Zonotope(RAcurr, RBcurr, RCcurr);
//        //A5PolyLogicalZonotope A5PolyZonotope(RAcurr, RBcurr, RCcurr);
//
//        //ReverseQueue indexQueue(RClength);
//        ReverseQueue indexQueue = initializeReverseQueue(RClength);
//
//        int relativeIndex = initialRClastZTind;
//
//        /*  if (RAcurr[4].Point == 1 && RAcurr[5].Point == 0 && RBcurr[7].Point == 0) {
//              outputString = " [Final step]  RC[8]&[9] = " + std::to_string(RCcurr[8].Point) + ',' + std::to_string(RCcurr[9].Point) + " @ " + Helper::GetCurrentTime();
//              std::cout << outputString << std::endl;
//          }*/
//        int index = 0;
//        bool isValid;
//        bool clkCondArray[4] = { false, false, false, false };
//        while (true)
//        {
//            while (index < threeBitsTableLength)
//            {
//                // if the relativeIndex is less than 4 then we are working on RB & RC only 
//                if (relativeIndex < 4)
//                {
//                    if (relativeIndex == 0 && index > 1) // two values for RC 0 or 1 are tested now. so let's break
//                        break;
//                    if (index > 3)  // all four values for RC and RB are tested now. so let's break
//                        break;
//                }
//                else
//                    RAcurr[relativeIndex - 4] = threeBitsTruthTableZonotope[index * 3 + 0];//[0];
//                if (relativeIndex > 0)
//                    RBcurr[relativeIndex - 1] = threeBitsTruthTableZonotope[index * 3 + 1];// [1] ;
//                RCcurr[relativeIndex] = threeBitsTruthTableZonotope[index * 3 + 2];// [2] ;
//
//                isValid = false;
//            /*    if (isExactPoly)
//                {
//                    isValid = A5PolyZonotope.IsValidKey();
//                }
//                else
//                {*/
//
//                    A5LogicalZonotopeQueue::MajorityFunction(RAcurr[8], RBcurr[10], RCcurr[10], clkCondArray);
//                    if (clkCondArray[0])
//                        isValid = A5Zonotope.IsValidKey('A');
//                    if (clkCondArray[1] && !isValid)
//                        isValid = A5Zonotope.IsValidKey('B');
//                    if (clkCondArray[2] && !isValid)
//                        isValid = A5Zonotope.IsValidKey('C');
//                    if (clkCondArray[3] && !isValid)
//                        isValid = A5Zonotope.IsValidKey('D');
//               // }
//                if (isValid)
//                {
//                    if (relativeIndex == 0)
//                    {
//                        std::cout << "\n*** We found a Key @ " << Helper::GetCurrentTime() << "***\n";
//                        Helper::PrintRegisters(RAcurr, RBcurr, RCcurr);
//                        return;
//                    }
//                    relativeIndex--;
//                   // indexQueue.Enqueue(index);
//                    Enqueue(indexQueue, index);
//                    index = 0;
//                }
//                else
//                    index++;
//            }
//
//            if (QueueSize(indexQueue) != 0)
//            {
//                if (relativeIndex < initialRClastZTind)
//                {
//                    RCcurr[relativeIndex] = tempPoint;
//                   // index = indexQueue.Dequeue() + 1;
//                    index = Dequeue(indexQueue) + 1;
//
//                    if (relativeIndex > 0)
//                    {
//                        RBcurr[relativeIndex - 1] = tempPoint;
//                        if (relativeIndex > 3)
//                            RAcurr[relativeIndex - 4] = tempPoint;
//                    }
//                    relativeIndex++;
//                }
//            }
//            else
//            {
//                return;
//            }
//        }
//    }

