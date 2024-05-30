#define MultiCard true 
#include "cuda_runtime_api.h"
#include <time.h>
#include <iostream>
#include <vector>
#include "TestCases.cpp"
#include "Helper.cpp"
#include <omp.h>
#include <tbb/concurrent_vector.h>
#include "device_launch_parameters.h"
#include <stdio.h>
#include "A5Breaker_LogicalZonotope.cu"
#include "A5-1-Breaker.h"

#pragma once

bool useTestingKey;
bool useKnownRandom;
int RAkey[RAlength];
int RBkey[RBlength];
int RCkey[RClength];


__device__  __constant__ size_t perThreadMemorySize = (d_RAlength + d_RBlength + d_RClength) * sizeof(uint8_t);

__constant__ __device__   int threeBitsTableLength = 8;
 __device__   bool isKeyFound = false;



__global__ void  FindValidCompinationsGPU  (uint8_t* d_AssumedBitstruthTableZonotope,int** outResult, int * outResultVector, int* d_outStream, int d_count)
{
    //int L = static_cast<int>(std::pow(2, noAssumedBits));
    int itdx = blockIdx.x * blockDim.x + threadIdx.x;
   // uint8_t tempPoint = uint8_t{ 0, 1 };
    // int i = 0, j = 0, k = 1;

    int i = itdx & 0x1F;
    int j = (itdx >> 5) & 0x1F;
    int k = (itdx >> 10) & 0x1F;

    uint8_t tempRAtask[d_RAlength];
    uint8_t tempRBtask[d_RBlength];
    uint8_t tempRCtask[d_RClength];

    GenerateLogicalZonotopeRegisterDevice(tempRAtask, d_RAlength);
    GenerateLogicalZonotopeRegisterDevice(tempRBtask, d_RBlength);
    GenerateLogicalZonotopeRegisterDevice(tempRCtask, d_RClength);

    // Fill last noBits elements of tempRAtask with a row from AssumedBitstruthTableZonotope
    FillLastNBitsWithRowDevice(tempRAtask, d_RAlength, d_AssumedBitstruthTableZonotope, i, d_noAssumedBits);
    FillLastNBitsWithRowDevice(tempRBtask, d_RBlength, d_AssumedBitstruthTableZonotope, j, d_noAssumedBits);
    FillLastNBitsWithRowDevice(tempRCtask, d_RClength, d_AssumedBitstruthTableZonotope, k, d_noAssumedBits);
   /* for (size_t index = 0; index < d_noAssumedBits; index++)
    {
        tempRAtask[d_RAlength - index].Point = (i & (1 << index)) ? 1 : 0;
        tempRBtask[d_RBlength - index].Point = (j & (1 << index)) ? 1 : 0;
        tempRCtask[d_RClength - index].Point = (k & (1 << index)) ? 1 : 0;
        tempRAtask[d_RAlength - index].Generator = 0;
        tempRBtask[d_RBlength - index].Generator = 0;
        tempRCtask[d_RClength - index].Generator = 0;

    }*/
    // PrintRegistersDevice(tempRAtask, tempRBtask, tempRCtask);
     // Create A5LogicalZonotopeQueue with temporary arrays
    A5LogicalZonotopeQueue a5;
     InitializeA5LogicalZonotopeQueue(&a5, tempRAtask, tempRBtask, tempRCtask, d_outStream, d_count);

    bool isValid = false;
    // Explore all clocking branches as the clocking bits are uncertain
    isValid = IsValidKey(a5, 'A');
    if (!isValid) isValid = IsValidKey(a5, 'B');
    if (!isValid) isValid = IsValidKey(a5, 'C');
    if (!isValid) isValid = IsValidKey(a5, 'D');

    if (isValid) {
       // printf("{%d} valid com found {%d},{%d}{%d} \n", itdx, i, j, k);

        int ptr[3] = { i, j, k };
        outResult[itdx] = ptr;

        outResultVector[3 * itdx] = i;
        outResultVector[3 * itdx +1] = j;
        outResultVector[3 * itdx +2] = k;


        //outResult[3 * itdx] = i;
        //outResult[3 * itdx + 1] = j;
        //outResult[3 * itdx + 2] = k;

    }
    else
    {
      // printf("{%d} com is not valid {%d},{%d}{%d} \n", itdx, i, j, k);

        outResult[itdx] = NULL;

        outResultVector[3 * itdx] = -1;
        outResultVector[3 * itdx + 1] = -1;
        outResultVector[3 * itdx + 2] = -1;

        /*outResult[3 * itdx] = NULL;
        outResult[3 * itdx + 1] = NULL;
        outResult[3 * itdx + 2] = NULL;*/
    }

}


__global__ void FindA5Key(const int* __restrict__ outResultVector, const uint8_t* __restrict__ AssumedBitstruthTableZonotope,
    const uint8_t* __restrict__ threeBitsTruthTableZonotope, const int* __restrict__ d_outStream, int  d_count)
{
    // printf("\n ******** GPU FindA5Key Started 0 ******** \n");

    int itdx = blockIdx.x * blockDim.x + threadIdx.x;

    int idx = 3 * itdx, jdx = 3 * itdx + 1, kdx = 3 * itdx + 2;



    if (idx >= 10752 || jdx >= 10750 || kdx >= 10752) {
        printf("Thread %d: Index out of bounds (idx: %d, jdx: %d, kdx: %d)\n", itdx, idx, jdx, kdx);

       return;
    }
    int i = outResultVector[idx];
    int j = outResultVector[jdx];
    int k = outResultVector[kdx];
    printf("\n ******** This is combination is i=%d  j=%d  k=%d ******** \n", i, j, k);

    uint8_t threeBitsLocal[3 * 8];
    for (size_t i = 0; i < 3*8; i++)
    {
        threeBitsLocal[i] = threeBitsTruthTableZonotope[i];

    }

 /*   if ( kdx >= 43000) {
        printf("Thread %d: Index out of bounds (idx: %d, jdx: %d, kdx: %d)\n", itdx, idx, jdx, kdx);
        return;
    }*/



    // printf("\n ******** GPU FindA5Key Started 1 ******** \n");


 /*   if (i == 0 && j == 0)
    {
        printf("\n ******** This is might be a valid combination k=%d ******** \n", k);
    }*/

  
    //// Calculate memory offset for this thread
    //uint8_t* RAcurr = &d_memory[itdx * perThreadMemorySize / sizeof(uint8_t)];
    //uint8_t* RBcurr = RAcurr + RAlength;
    //uint8_t* RCcurr = RBcurr + RBlength;

  /*  extern __shared__ uint8_t sharedMem[];
    uint8_t* RAcurr = sharedMem;
    uint8_t* RBcurr = &sharedMem[d_RAlength];
    uint8_t* RCcurr = &sharedMem[d_RAlength + d_RBlength];*/


    uint8_t RAcurr[d_RAlength];
    uint8_t RBcurr[d_RBlength];
    uint8_t RCcurr[d_RClength];

  //  uint8_t  point = { 0,1 };
    GenerateLogicalZonotopeRegisterDevice(RAcurr, d_RAlength);
    GenerateLogicalZonotopeRegisterDevice(RBcurr, d_RBlength);
    GenerateLogicalZonotopeRegisterDevice(RCcurr, d_RClength);

    /*  printf("\n*** Printing initial values  \n ");
      PrintRegistersDevice(tempRAtask, tempRBtask, tempRCtask);*/


    ////  // Assuming FillLastNBitsWithRow is a function to fill the last N bits with a row from the truthTable
    //FillLastNBitsWithRowDevice(RAcurr, d_RAlength, AssumedBitstruthTableZonotope, i, d_noAssumedBits);
    //FillLastNBitsWithRowDevice(RBcurr, d_RBlength, AssumedBitstruthTableZonotope, j, d_noAssumedBits);
    //FillLastNBitsWithRowDevice(RCcurr, d_RClength, AssumedBitstruthTableZonotope, k, d_noAssumedBits);

    //this one is working fine 
    for (size_t index = 0; index < d_noAssumedBits; index++)
    {
        RAcurr[d_RAlength - d_noAssumedBits + index] = AssumedBitstruthTableZonotope[i * d_noAssumedBits + index];
        RBcurr[d_RBlength - d_noAssumedBits + index] = AssumedBitstruthTableZonotope[j * d_noAssumedBits + index];
        RCcurr[d_RClength - d_noAssumedBits + index] = AssumedBitstruthTableZonotope[k * d_noAssumedBits + index];

    }

    //for (size_t index = 0; index < d_noAssumedBits; index++)
    //{
    //      RAcurr[d_RAlength - d_noAssumedBits + index].Point = (i* d_noAssumedBits & (1 << index)) ? 1 : 0;
    //      RBcurr[d_RBlength - d_noAssumedBits + index].Point = (j* d_noAssumedBits & (1 << index)) ? 1 : 0;
    //      RCcurr[d_RClength - d_noAssumedBits + index].Point = (k* d_noAssumedBits & (1 << index)) ? 1 : 0;
    //      RAcurr[d_RAlength - d_noAssumedBits + index].Generator = 0;
    //      RBcurr[d_RBlength - d_noAssumedBits + index].Generator = 0;
    //      RCcurr[d_RClength - d_noAssumedBits + index].Generator = 0;

    //}
  

    /*  printf("\n*** Printing registed filled with valid combination  \n ");
      PrintRegistersDevice(tempRAtask, tempRBtask, tempRCtask);*/

    int relativeIndex = d_RAlength - d_noAssumedBits + 3;
    // Helper::PrintRegisters(tempRAtask, tempRBtask, tempRCtask);

    // //finalStep(tempRAtask, tempRBtask, tempRCtask, RCInitialIndex);
    //uint8_t* RAcurr = tempRAtask;
    //uint8_t* RBcurr = tempRBtask;
    //uint8_t* RCcurr = tempRCtask;


    // std::string outputString;
    A5LogicalZonotopeQueue A5Zonotope;
    InitializeA5LogicalZonotopeQueue(&A5Zonotope,  RAcurr, RBcurr, RCcurr, d_outStream, d_count);
    //A5PolyLogicalZonotope A5PolyZonotope(RAcurr, RBcurr, RCcurr);

    //ReverseQueue indexQueue(RClength);
    ReverseQueue indexQueue;
    initializeReverseQueue(&indexQueue);

    /*  if (RAcurr[4].Point == 1 && RAcurr[5].Point == 0 && RBcurr[7].Point == 0) {
          outputString = " [Final step]  RC[8]&[9] = " + std::to_string(RCcurr[8].Point) + ',' + std::to_string(RCcurr[9].Point) + " @ " + Helper::GetCurrentTime();
          std::cout << outputString << std::endl;
      }*/
    int index = 0;
    bool isValid;
    bool clkCondArray[4] = { false, false, false, false };
    while (true)
    {
       

       /* if (iterations > 200000);
        break;*/

        while (index < threeBitsTableLength)
        {
           // testing code 
            /*   if (i == 0 && j == 0 && k == 1)
            {
                if (relativeIndex == 17)
                    index = 1;
                else if (relativeIndex == 16)
                    index = 0;
                else if (relativeIndex == 15)
                {
                    // printf("\nrelativeIndex = 15");
                    index = 1;
                }
                else if (relativeIndex == 14)
                {
                    // printf("\nrelativeIndex = 14");
                    index = 2;
                }
                else if (relativeIndex == 13)
                    index = 3;
                else if (relativeIndex == 12)
                    index = 1;
             else if (relativeIndex == 11)
                    index = 4;

            }*/

            // if the relativeIndex is less than 4 then we are working on RB & RC only 
            if (relativeIndex < 4)
            {
                if (relativeIndex == 0 && index > 1) // two values for RC 0 or 1 are tested now. so let's break
                    break;
                if (index > 3)  // all four values for RC and RB are tested now. so let's break
                    break;
            }
            else
                RAcurr[relativeIndex - 4] = threeBitsTruthTableZonotope[index * 3 + 0];//[0];
            if (relativeIndex > 0)
                RBcurr[relativeIndex - 1] = threeBitsTruthTableZonotope[index * 3 + 1];// [1] ;
            RCcurr[relativeIndex] = threeBitsTruthTableZonotope[index * 3 + 2];// [2] ;

            /* printf("\n*** Printing registed filled with three bits more   \n ");
             PrintRegistersDevice(RAcurr, RBcurr, RCcurr);*/
             // Helper::PrintRegisters(RAcurr, RBcurr, RCcurr);

            isValid = false;
            /*    if (isExactPoly)
                {
                    isValid = A5PolyZonotope.IsValidKey();
                }
                else
                {*/

                //TODO: the Majority Function can be skipped at the first few iterations
            MajorityFunction(RAcurr[8], RBcurr[10], RCcurr[10], clkCondArray);
            //   printf("\n***  MajorityFunction success \n ");

            if (clkCondArray[0])
            {
                isValid = IsValidKey(A5Zonotope, 'A');
            }
            if (clkCondArray[1] && !isValid)
                isValid = IsValidKey(A5Zonotope, 'B');
            if (clkCondArray[2] && !isValid)
                isValid = IsValidKey(A5Zonotope, 'C');
            if (clkCondArray[3] && !isValid)
                isValid = IsValidKey(A5Zonotope, 'D');
            // }
            if (isValid)
            {
                if (relativeIndex == 0)
                {
                    isKeyFound = true;
                    printf("\n*** We found a Key \n");
                    PrintRegistersDevice(RAcurr, RBcurr, RCcurr);

                    //std::cout << "\n*** We found a Key @ " << Helper::GetCurrentTime() << "***\n";
                   // Helper::PrintRegisters(RAcurr, RBcurr, RCcurr);
                    return;
                }
                relativeIndex--;
                // indexQueue.Enqueue(index);
                Enqueue(indexQueue, index);
                index = 0;
            }
            else
                index++;
        }
        if (isKeyFound)
            return;
        if (QueueSize(indexQueue) != 0)
        {
                RCcurr[relativeIndex] = 2;
                // index = indexQueue.Dequeue() + 1;
                index = Dequeue(indexQueue) + 1;

                if (relativeIndex > 0)
                {
                    RBcurr[relativeIndex - 1] = 2;
                    if (relativeIndex > 3)
                        RAcurr[relativeIndex - 4] = 2;
                }
                relativeIndex++;
        }
        else
        {
            printf("\n thread %d finished i=%d  j=%d  k=%d ******** \n", itdx, i, j, k);
            return;
        }
       
       // printf("\n thread %d finished \n", itdx);

    }
    printf("\n thread %d finished \n", itdx);





  //  __syncthreads();

    /*

      if (isMixedMode)
          key = A5Breaker_ExactPoly_A5RFBZT_12_DeepModeLoop_A5Loop(tempRAtask.data(), tempRBtask.data(), tempRCtask.data(), indexText);
      else
          key = A5Breaker_LogicalZonotope_A5RFBZT_12_DeepModeLoop_A5Loop(tempRAtask.data(), tempRBtask.data(), tempRCtask.data(), indexText);
          */

          /* std::cout << "\n[Main Thread] " << indexText << " THREAD FINISHED @  " << Helper::GetCurrentTime() << std::endl;

           delete[] tempRAtask;
           delete[] tempRBtask;
           delete[] tempRCtask;

       }});*/



}



__global__ void test_finalstep(int* validGuess, uint8_t* AssumedThTbl, uint8_t* threeThTbl, int* d_outStream, int d_count)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    printf("%d, \n", idx);

    printf("\n GPU Assumed BITS  \n");
    for (int i = 0; i < 160; i++)
    {
        printf("{%d,%d} ,", AssumedThTbl[i], AssumedThTbl[i]);

    }

    printf("\n GPU Three BITS  \n");
    for (int i = 0; i < 24; i++)
    {
        printf("{%d,%d} ,", threeThTbl[i], threeThTbl[i]);

    }

    printf("\n GPU VALID Guess BITS  \n");
    for (int i = 0; i < 100; i++)
    {
        printf("{%d, %d, %d}\n ,", validGuess[3 * i], validGuess[3 * i + 1], validGuess[3 * i + 2]);

    }
    printf("\n GPU count = %d  \n", d_count);

    printf("\n GPU VALID Out Stream  \n");
    printf("\n out stream ={");

    for (int i = 0; i < d_count; i++)
    {
        printf("%d, ", d_outStream[i]);

    }
    printf("}");




    /* uint8_t* RA = GenerateLogicalZonotopeRegister(d_RAlength);
     uint8_t* RB = GenerateLogicalZonotopeRegister(d_RBlength);
     uint8_t* RC = GenerateLogicalZonotopeRegister(d_RClength);

     FillLastNBitsWithRow(RA, d_RAlength, AssumedThTbl, 0, d_noAssumedBits);
     FillLastNBitsWithRow(RB, d_RBlength, AssumedThTbl, 0, d_noAssumedBits);
     FillLastNBitsWithRow(RC, d_RClength, AssumedThTbl, 1, d_noAssumedBits);*/


     /*   printf("\n GPU Content of RA,RB,RC Registers  \n");

        printRegisters(RA, RB, RC);*/

}





// Parse the configuration file and generate the initial Key Stream. 
void Initialization()
{

    Helper::ParseConfigFile("./App.config", RAkey, RBkey, RCkey);

    std::cout << "\n**** Attacking Paramters ****\n";
    std::cout << "Key stream length  " << count << std::endl;
    std::cout << "No assumed bits  " << noAssumedBits << std::endl;
    std::cout << "2nd level assumed bits  " << deepNoAssumedBits << std::endl;

    std::cout << "\n**** Secret Key  ****\n";
    Helper::PrintRegisters(RAkey, RBkey, RCkey);
    outStream = A5_1::GenerateSequence(RAkey, RBkey, RCkey, count);

    std::cout << "\n**** Generated Key Stream **** " << std::endl;
    for (size_t i = 0; i < count; i++)
    {
        std::cout << outStream[i] << ",";
    }
    std::cout << std::endl;



}



// Parallel simulation logic
void FindValidCompinations(std::vector<int*>& validGuessConBag, int noAssumedBits)
{
    int L = static_cast<int>(std::pow(2, noAssumedBits));
    static uint8_t* AssumedBitstruthTableZonotope = Helper::GetTruthTableZonotope(noAssumedBits);


    uint8_t RAinit[RAlength];
    uint8_t RBinit[RBlength];
    uint8_t RCinit[RClength];

    Helper::GenerateLogicalZonotopeRegister(RAinit, RAlength);
    Helper::GenerateLogicalZonotopeRegister(RBinit, RBlength);
    Helper::GenerateLogicalZonotopeRegister(RCinit, RClength);

    // Parallel simulation loop
  //  std::vector<std::vector<int*>> privateBags(Concurrency::GetProcessorCount()); // Private bags for each thread


    tbb::concurrent_vector<std::vector<int*>> privateBags(tbb::this_task_arena::max_concurrency());

    // #pragma omp parallel for
    //for (int index = 0; index < L; index++) {
    tbb::parallel_for(0, L, [&](int index) {
        // Create temporary copies of RA, RB, RC
    /*    uint8_t tempRAtask[RAlength];
        uint8_t tempRBtask[RAlength];
        uint8_t tempRCtask[RAlength];*/

        uint8_t tempRAtask[RAlength];
        uint8_t tempRBtask[RBlength];
        uint8_t tempRCtask[RClength];

        // Copy values from RA, RB, RC to temporary arrays
        std::copy(RAinit, RAinit + RAlength, tempRAtask);
        std::copy(RBinit, RBinit + RBlength, tempRBtask);
        std::copy(RCinit, RCinit + RClength, tempRCtask);

        // Fill last noBits elements of tempRAtask with a row from AssumedBitstruthTableZonotope
        Helper::FillLastNBitsWithRow(tempRAtask, RAlength, AssumedBitstruthTableZonotope, index, noAssumedBits);
        A5LogicalZonotopeQueue a5;
        // Create A5LogicalZonotopeQueue with temporary arrays
         InitializeA5LogicalZonotopeQueue(&a5, tempRAtask, tempRBtask, tempRCtask, outStream, count);
        //  A5PolyLogicalZonotope A5PolyZonotope(tempRAtask, tempRBtask, tempRCtask);


          // Nested loops for RB and RC
        for (int j = 0; j < L; j++) {
            Helper::FillLastNBitsWithRow(tempRBtask, RBlength, AssumedBitstruthTableZonotope, j, noAssumedBits);

            for (int k = 0; k < L; k++) {
                Helper::FillLastNBitsWithRow(tempRCtask, RClength, AssumedBitstruthTableZonotope, k, noAssumedBits);
                bool isValid = false;

                //Helper::PrintRegisters(tempRAtask, tempRBtask, tempRCtask);
                if (isExactPoly)
                {
                    // isValid = A5PolyZonotope.IsValidKey();
                }
                else
                {
                    // Explore all clocking branches as the clocking bits are uncertain
                    isValid = IsValidKey(a5, 'A');
                    if (!isValid) isValid = IsValidKey(a5, 'B');
                    if (!isValid) isValid = IsValidKey(a5, 'C');
                    if (!isValid) isValid = IsValidKey(a5, 'D');
                    //    std::cout << "is valid = " << std::boolalpha << isValid << "\n" << std::endl;
                }
                // If key is valid, add the combination to the validGuessConBag
                if (isValid) {
                    int* ptr = new int[3] { index, j, k };

                    // int ptr[3];
                    /* ptr[0] = index;
                     ptr[1] = j;
                     ptr[2] = k;*/

                     // validGuessConBag.push_back(ptr);

                    privateBags[tbb::this_task_arena::current_thread_index()].push_back(ptr);
                }
            }
        }

  
        });

    // Merge private bags into the main bag
    for (auto& privateBag : privateBags) {
        validGuessConBag.insert(validGuessConBag.end(), privateBag.begin(), privateBag.end());
    }
    privateBags.clear();

    //for (int i = 0; i < omp_get_num_threads(); i++) {
    //    validGuessConBag.insert(validGuessConBag.end(), privateBags[i].begin(), privateBags[i].end());
    //    privateBags[i].clear();  // Clear the private bag after merging
    //}

    // Merge private bags into the main bag
   /* for (auto& privateBag : privateBags) {
        validGuessConBag.insert(validGuessConBag.end(), privateBag.begin(), privateBag.end());
    }*/



}







int main()
{
    cudaFree(0);
    std::cout << "==============================================================\n";
    std::cout << "             A5 Breaker using logicalZonotope !\n";
    std::cout << "==============================================================\n";


    //RunTestCases();
    //Helper::A5StreamCalcultionTime(100);
   // DeviceProperties();
    //
    
      // Create a thread that runs the printCurrentDateTime function
  //  std::thread backgroundThread(Helper::printCurrentDateTime);

    // Detach the thread so it runs independently
  //  backgroundThread.detach();

    Initialization();
  
    std::vector<int*> validGuessConBag;
    FindValidCompinationsCPU(validGuessConBag);

          //std::for_each( validGuessConBag.begin(), validGuessConBag.end(), [&](int* index) {
      //#pragma omp parallel for num_threads(8)
      //for (int it = 0; it < static_cast<int>(validGuessConBag.size()); ++it) {
      //    int* index = validGuessConBag[it];
      //    int i = index[0], j = index[1], k = index[2];


    //lenght is defined by (the raws of truth table * no bits) because I have all in one dimension array 
    int validGuessVectorSize = validGuessConBag.size() * 3;
    int* validGuessVector = new int[validGuessVectorSize];

    for (int i = 0; i < validGuessConBag.size(); i++)
    {
        validGuessVector[3 * i] = validGuessConBag[i][0];
        validGuessVector[3 * i + 1] = validGuessConBag[i][1];
        validGuessVector[3 * i + 2] = validGuessConBag[i][2];
    }


   /* printf("\n CPU Assumed BITS  \n");
    for (int i = 0; i < assumedBitsTruthTblLen; i++)
    {
        printf("{%d,%d} ,", AssumedBitstruthTableZonotope[i].Point, AssumedBitstruthTableZonotope[i].Generator);

    }

    printf("\n CPU Three BITS  \n");
    for (int i = 0; i < threeBitsTruthTblLen; i++)
    {
        printf("{%d,%d} ,", threeBitsTruthTableZonotope[i].Point, threeBitsTruthTableZonotope[i].Generator);

    }

    printf("\n CPU VALID Guess BITS  \n");
    for (int i = 0; i < 100; i++)
    {
        printf("{%d, %d, %d}\n ,", validGuessConBag[i][0], validGuessConBag[i][1], validGuessConBag[i][2]);

    }*/

    /*******  Cuda work section *******/

    std::cout << " \n======== GPU Section: =========== " << std::endl;
    int numDevices;
    checkCudaErrors(cudaGetDeviceCount(&numDevices));

    std::cout << "******* No of GPU Cards is: " << numDevices << " *******" << std::endl;


    uint8_t* d_threeBitsTruthTableZonotope = NULL;
    int* d_validGuessConBag = NULL;
    int* d_outStream = NULL;
    uint8_t* d_AssumedBitstruthTableZonotope = NULL;
    uint8_t* AssumedBitstruthTableZonotope = Helper::GetTruthTableZonotope(noAssumedBits);

    int partSize = validGuessVectorSize / 4;
    int* d_VectorParts[4];
    if (MultiCard)
    {
        for (size_t i = 0; i < numDevices; i++)
        {
            checkCudaErrors(cudaSetDevice(i));
            checkCudaErrors(cudaMalloc((void**)&d_VectorParts[i], partSize * sizeof(int)));
            checkCudaErrors(cudaMemcpy(d_VectorParts[i], validGuessVector + i * partSize, partSize * sizeof(int), cudaMemcpyHostToDevice));
        }
    }
  
    AllocateGPUMemory(d_outStream, d_AssumedBitstruthTableZonotope,AssumedBitstruthTableZonotope, d_threeBitsTruthTableZonotope,
        d_validGuessConBag, validGuessVectorSize, validGuessVector);

    /*******  Find valid combinations section *******/
    /*std::vector<int> validItemsVector;*/
    LaunchFindValidCompinationsKernel(d_AssumedBitstruthTableZonotope, d_outStream);
    /*int validItemsVectorSize = validItemsVector.size();
    std::sort(validGuessConBag.begin(), validGuessConBag.end(), Helper::compareIntArrays);*/

    /******* FindA5Key Section *******/
 /*   int numThreads = 5;
    cudaError_t cuda_err;

    cuda_err = cudaMalloc((void**)&d_validGuessConBag, validItemsVectorSize * sizeof(int));
    if (cuda_err != cudaSuccess) {
        std::cout << "Error Allocating the d_validGuessConBag.\n";
    }

    cuda_err = cudaMemcpy(d_validGuessConBag, validItemsVector.data(), validItemsVectorSize * sizeof(int), cudaMemcpyHostToDevice);
    if (cuda_err != cudaSuccess) {
        std::cout << "Error Copying the d_validGuessConBag.\n";
    }*/

 /*   size_t sharedMemSize = (d_RAlength + d_RBlength + d_RClength) * sizeof(uint8_t);
    size_t totalMemorySize = numThreads * (RAlength + RBlength + RClength) * sizeof(uint8_t);
    uint8_t* d_memory;
    cudaMalloc(&d_memory, totalMemorySize);*/
    
    std::cout << "\n[GPU call] FindA5Key " << " Started  @  " << Helper::GetCurrentTime() << std::endl;

    // Launch kernels on each GPU
    int threadsPerBlock = 256;
    int blocksPerGrid = (partSize + threadsPerBlock * 3 - 1) / (threadsPerBlock * 3);

    if (MultiCard)
    {
        int i = 0;
            checkCudaErrors(cudaSetDevice(i));
            FindA5Key << <14, 256 >> > (d_validGuessConBag, d_AssumedBitstruthTableZonotope, d_threeBitsTruthTableZonotope, d_outStream, count);
    }
    else
    {
        //FindA5Key << <112, 128 >> > (d_validGuessConBag, d_AssumedBitstruthTableZonotope, d_threeBitsTruthTableZonotope, d_outStream, count);
        FindA5Key << <112, 128 >> > (d_validGuessConBag, d_AssumedBitstruthTableZonotope, d_threeBitsTruthTableZonotope, d_outStream, count);
        cudaDeviceSynchronize();
        // FindA5Key(validGuessConBag, AssumedBitstruthTableZonotope, threeBitsTruthTableZonotope);

    }


  

    std::cout << "\n[GPU call] FindA5Key " << " Finished  @  " << Helper::GetCurrentTime() << std::endl;




    /* uint8_t* d_tempRA = NULL;
     uint8_t* d_tempRB = NULL;
     uint8_t* d_tempRC = NULL;

     cuda_err = cudaMalloc((void**)&d_tempRA, sizeof(uint8_t) * RAlength);
     if (cuda_err != cudaSuccess) {
         std::cout << "Error Allocating the d_tempRA.\n";
     }
     cuda_err = cudaMalloc((void**)&d_tempRB, sizeof(uint8_t) * RBlength);
     if (cuda_err != cudaSuccess) {
         std::cout << "Error Allocating the RB.\n";
     }
     cuda_err = cudaMalloc((void**)&d_tempRC, sizeof(uint8_t) * RClength);
     if (cuda_err != cudaSuccess) {
         std::cout << "Error Allocating the RC.\n";
     }*/

     //// Copy the data to GPU
     //cuda_err = cudaMemcpy(d_tempRA, tempRAtask, sizeof(uint8_t) * RAlength, cudaMemcpyHostToDevice);
     //if (cuda_err != cudaSuccess) {
     //    std::cout << "Error Copying the RA.\n";
     //}
     //cuda_err = cudaMemcpy(d_tempRB, tempRBtask, sizeof(uint8_t) * RBlength, cudaMemcpyHostToDevice);
     //if (cuda_err != cudaSuccess) {
     //    std::cout << "Error Copying the RA.\n";
     //}
     //cuda_err = cudaMemcpy(d_tempRC, tempRCtask, sizeof(uint8_t) * RClength, cudaMemcpyHostToDevice);
     //if (cuda_err != cudaSuccess) {
     //    std::cout << "Error Copying the RA.\n";
     //}



     /*

       if (isMixedMode)
           key = A5Breaker_ExactPoly_A5RFBZT_12_DeepModeLoop_A5Loop(tempRAtask.data(), tempRBtask.data(), tempRCtask.data(), indexText);
       else
           key = A5Breaker_LogicalZonotope_A5RFBZT_12_DeepModeLoop_A5Loop(tempRAtask.data(), tempRBtask.data(), tempRCtask.data(), indexText);
           */

           // std::cout << "\n[Main Thread] " << indexText << " THREAD FINISHED @  " << Helper::GetCurrentTime() << std::endl;

          /*  delete[] tempRAtask;
            delete[] tempRBtask;
            delete[] tempRCtask;*/

            // }});




        // A5LogicalZonotopeQueue::_outStream = &outStream;
         //A5LogicalZonotopeQueue::_count = count;


    return 0;
}


void LaunchFindValidCompinationsKernel( uint8_t* d_AssumedBitstruthTableZonotope, int* d_outStream)
{
    std::vector<int> validItemsVector;
    int* outResultVector;
    int noPossibilities = static_cast<int>(std::pow(2, noAssumedBits));
    int totalIterations = noPossibilities * noPossibilities * noPossibilities;

    int** outResult; // Device pointer to store output
    // Allocate memory on the device to store the output
    cudaMalloc((void**)&outResult, totalIterations * sizeof(int*));
    cudaMalloc((void**)&outResultVector,3* totalIterations * sizeof(int));


    std::cout << "\n[GPU call] Find ValidCompinations " << " Started  @  " << Helper::GetCurrentTime() << std::endl;
    FindValidCompinationsGPU << <noPossibilities * noPossibilities, noPossibilities >> > (d_AssumedBitstruthTableZonotope, outResult, outResultVector, d_outStream, count);
    //FindValidCompinationsGPU << <1, 128 >> > (outResult);
    std::cout << "\n[GPU call] Find ValidCompinations " << " Finished  @  " << Helper::GetCurrentTime() << std::endl;

    // Check for kernel launch errors
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess) {
        std::cerr << "CUDA error: " << cudaGetErrorString(err) << std::endl;
    }

    cudaDeviceSynchronize();

    std::vector<int*> outResultvalidGuessConBag(totalIterations);
    cudaMemcpy(outResultvalidGuessConBag.data(), outResult, totalIterations * sizeof(int*), cudaMemcpyDeviceToHost);

    std::vector<int*> validItems;
    for (int i = 0; i < outResultvalidGuessConBag.size(); i++) {
        if (outResultvalidGuessConBag[i] != nullptr) {
            // std::cout << outResultvalidGuessConBag[i][0] << ", " << outResultvalidGuessConBag[i][1] << ", " << outResultvalidGuessConBag[i][2] << std::endl;
            validItems.push_back(outResultvalidGuessConBag[i]); // Push valid items to the new vector
        }
    }
    std::cout << "Total number of valid items: " << validItems.size() << std::endl;


    std::vector<int> h_outResultVector(3*totalIterations);
    cudaMemcpy(h_outResultVector.data(), outResultVector, 3* totalIterations * sizeof(int), cudaMemcpyDeviceToHost);

    
    for (int i = 0; i < h_outResultVector.size(); i++) {
        if (h_outResultVector[i] != -1) {
            // std::cout << outResultvalidGuessConBag[i][0] << ", " << outResultvalidGuessConBag[i][1] << ", " << outResultvalidGuessConBag[i][2] << std::endl;
            validItemsVector.push_back(h_outResultVector[i]); // Push valid items to the new vector
        }
    }
    std::cout << "Total number of valid items VECTOR: " << validItemsVector.size()/3 << std::endl;
    
//    std::vector<int*> validGuessArrays(validItemsVector.size() / 3);
//    int* tmpGuess;
//    for (size_t i = 0; i < validItemsVector.size() / 3;)
//    {
//        tmpGuess = new int [3]{ validItemsVector[i],validItemsVector[i + 1], validItemsVector[i + 2] };
//        validGuessArrays.push_back(tmpGuess);
//        i = i + 3;
//    }
//
////    std::sort(validGuessArrays.begin(), validGuessArrays.end(), Helper::compareIntArrays);
//
//
//    // Calculate the number of groups
//    int numGroups = validItemsVector.size() / 3;
//
//    // Initialize the indices vector
//    std::vector<int> indices(numGroups);
//    for (int i = 0; i < numGroups; ++i) {
//        indices[i] = i * 3;
//    }
//
//    // Sort the indices based on the comparison of groups
//    std::sort(indices.begin(), indices.end(),
//        [&validItemsVector](int a, int b) {
//            return Helper::compareGroups(validItemsVector, a, b);
//        });
//
//    // Create a new vector for sorted elements
//    std::vector<int> sortedVector(validItemsVector.size());
//    for (size_t i = 0; i < indices.size(); ++i) {
//        sortedVector[i * 3] = validItemsVector[indices[i]];
//        sortedVector[i * 3 + 1] = validItemsVector[indices[i] + 1];
//        sortedVector[i * 3 + 2] = validItemsVector[indices[i] + 2];
//    }
//
//    // Print the sorted results
//    for (size_t i = 0; i < sortedVector.size(); i += 3) {
//        std::cout << sortedVector[i] << " "
//            << sortedVector[i + 1] << " "
//            << sortedVector[i + 2] << std::endl;
//    }
}
//FindValidCompinationsCPU 
void FindValidCompinationsCPU(std::vector<int*>& validGuessConBag)
{

    std::cout << " ======== CPU Section: =========== " << std::endl;

    // Start the timer
    auto start = std::chrono::high_resolution_clock::now();
    FindValidCompinations(validGuessConBag, noAssumedBits);

    // Stop the timer
    auto stop = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(stop - start);
    std::cout << "Time taken by function: " << duration.count() << " milliseconds" << std::endl;

    std::cout << "Total Number of Guesses: " << validGuessConBag.size() << std::endl;

   //std::sort(validGuessConBag.begin(), validGuessConBag.end(), Helper::compareIntArrays);

   // for (const auto& guess : validGuessConBag) {
   // std::cout << "Valid Guess: {" << guess[0] << ", " << guess[1] << ", " << guess[2] << "}" << std::endl;
   // }

}


void AllocateGPUMemory(int*& d_outStream, uint8_t*& d_AssumedBitstruthTableZonotope, uint8_t* AssumedBitstruthTableZonotope,
    uint8_t*& d_threeBitsTruthTableZonotope, int*& d_validGuessConBag, int validGuessVectorSize, int* validGuessVector)
{

    int assumedBitsTruthTblLen = static_cast<int>(std::pow(2, noAssumedBits)) * noAssumedBits;
    int threeBitsTruthTblLen = static_cast<int>(std::pow(2, 3)) * 3;
    uint8_t* threeBitsTruthTableZonotope = Helper::GetTruthTableZonotope(1 * 3);

    checkCudaErrors(cudaMalloc((void**)&d_outStream, sizeof(int) * count));
    checkCudaErrors(cudaMemcpy(d_outStream, outStream, sizeof(int) * count, cudaMemcpyHostToDevice));
    
    checkCudaErrors(cudaMalloc((void**)&d_AssumedBitstruthTableZonotope, sizeof(uint8_t) * assumedBitsTruthTblLen));
    checkCudaErrors(cudaMemcpy(d_AssumedBitstruthTableZonotope, AssumedBitstruthTableZonotope, sizeof(uint8_t) * assumedBitsTruthTblLen, cudaMemcpyHostToDevice));

    checkCudaErrors(cudaMalloc((void**)&d_threeBitsTruthTableZonotope, sizeof(uint8_t) * threeBitsTruthTblLen));
    checkCudaErrors(cudaMemcpy(d_threeBitsTruthTableZonotope, threeBitsTruthTableZonotope, sizeof(uint8_t) * threeBitsTruthTblLen, cudaMemcpyHostToDevice));


    if (!MultiCard)
    {

        checkCudaErrors(cudaMalloc((void**)&d_validGuessConBag, validGuessVectorSize * sizeof(int)));
        checkCudaErrors(cudaMemcpy(d_validGuessConBag, validGuessVector, validGuessVectorSize * sizeof(int), cudaMemcpyHostToDevice));

    }

}


void checkCudaErrors(cudaError_t err) {
    if (err != cudaSuccess) {
        std::cerr << "CUDA error: " << cudaGetErrorString(err) << std::endl;
        exit(err);
    }
}

void DeviceProperties()
{
    cudaDeviceProp devprop;
    cudaGetDeviceProperties(&devprop, 0);
    std::cout << "Maximum number of thread: " << devprop.maxThreadsPerBlock << std::endl;
    std::cout << "maxThreadsDim : " << devprop.maxThreadsDim[0] << std::endl;
    std::cout << "Clockrate: " << devprop.clockRate << std::endl;

    std::cout << "Multi proccessor count: " << devprop.multiProcessorCount << std::endl;


    size_t memfree, memtoal;
    cudaMemGetInfo(&memfree, &memtoal);
    std::cout << "memory free: " << memfree / (1024 * 1024) << std::endl;
    //std::cout << "memory total: " << memtoal / (1024 * 1024) << std::endl;

    std::cout << "memory free: " << memfree / (1024 * 1024) << std::endl;



}

void RunTestCases()
{
    TestCases::TestAnd();
    TestCases::TestOr();
    TestCases::TestNot();
   //  TestCases::testReverseQueueSt();


    int n = 5;
    // Generate and print the truth table
    int* truthTable = Helper::GetTruthTable(n);
    // Helper::PrintTruthTable(truthTable, n);
     // Deallocate memory for the truth table
    delete[] truthTable;

    // Generate and print the logical zonotope truth table
    uint8_t* truthTableZonotope = Helper::GetTruthTableZonotope(n);
    // Helper::PrintTruthTableZonotope(truthTableZonotope, n);
}
