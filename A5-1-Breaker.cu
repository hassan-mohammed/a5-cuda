//// A5-1-Breaker.cpp : This file contains the 'main' function. Program execution begins and ends there.
////
//
//
//#include "cuda_runtime.h"
//#include <iostream>
//#include <vector>
//#include "TestCases.cpp"
//#include "A5Breaker_LogicalZonotope.cpp"
//#include "A5-1-Breaker.h"
//#include "Helper.cpp"
//#include <omp.h>
//#include <tbb/concurrent_vector.h>
//#include "A5LogicalZonotopeQueue.cpp"
//
//#include "device_launch_parameters.h"
//
//#include <stdio.h>
//
//#pragma once
////int A5LogicalZonotopeQueue::_count = 0;
////std::vector<int>* A5LogicalZonotopeQueue::_outStream = nullptr;
//
//// Global variables
//bool useTestingKey;
//bool useKnownRandom;
//int RA[RAlength];
//int RB[RBlength];
//int RC[RClength];
//LightLogicalZonotope* AssumedBitstruthTableZonotope;
//
//// Parse the configuration file and generate the initial Key Stream. 
//void Initialization()
//{
//
//    Helper::ParseConfigFile("App.config",RA, RB, RC);
//
//    std::cout << "\n**** Attacking Paramters ****\n";
//    std::cout << "Key stream length  " << count << std::endl;
//    std::cout << "No assumed bits  " << noAssumedBits << std::endl;
//    std::cout << "2nd level assumed bits  " << deepNoAssumedBits << std::endl;
//
//    std::cout << "\n**** Secret Key  ****\n";
//    Helper::PrintRegisters(RA, RB, RC);
//    outStream = A5_1::GenerateSequence(RA, RB, RC, count);
//
//    std::cout << "\n**** Generated Key Stream **** " << std::endl;
//    for (int value : outStream) {
//        std::cout << value << ",";
//    }
//    std::cout << std::endl;
//    AssumedBitstruthTableZonotope = Helper::GetTruthTableZonotope(noAssumedBits);
//
//
//}
//
//
//
//// Parallel simulation logic
//void FindValidCompinations(std::vector<int*>& validGuessConBag, int noAssumedBits)
//{
//    int L = static_cast<int>(std::pow(2, noAssumedBits));
//    LightLogicalZonotope* RA = Helper::GenerateLogicalZonotopeRegister(RAlength);
//    LightLogicalZonotope* RB = Helper::GenerateLogicalZonotopeRegister(RBlength);
//    LightLogicalZonotope* RC = Helper::GenerateLogicalZonotopeRegister(RClength);
//    // Parallel simulation loop
//  //  std::vector<std::vector<int*>> privateBags(Concurrency::GetProcessorCount()); // Private bags for each thread
//
//  
//    tbb::concurrent_vector<std::vector<int*>> privateBags(tbb::this_task_arena::max_concurrency());
//
//    // #pragma omp parallel for
//    //for (int index = 0; index < L; index++) {
//    tbb::parallel_for(0, L, [&](int index) {
//        // Create temporary copies of RA, RB, RC
//    /*    LightLogicalZonotope tempRAtask[RAlength];
//        LightLogicalZonotope tempRBtask[RAlength];
//        LightLogicalZonotope tempRCtask[RAlength];*/
//        LightLogicalZonotope* tempRAtask = new LightLogicalZonotope[RAlength];
//        LightLogicalZonotope* tempRBtask = new LightLogicalZonotope[RBlength];
//        LightLogicalZonotope* tempRCtask = new LightLogicalZonotope[RClength];
//
//        // Copy values from RA, RB, RC to temporary arrays
//        std::copy(RA, RA + RAlength, tempRAtask);
//        std::copy(RB, RB + RBlength, tempRBtask);
//        std::copy(RC, RC + RClength, tempRCtask);
//
//        // Fill last noBits elements of tempRAtask with a row from AssumedBitstruthTableZonotope
//        Helper::FillLastNBitsWithRow(tempRAtask, RAlength, AssumedBitstruthTableZonotope, index, noAssumedBits);
//
//        // Create A5LogicalZonotopeQueue with temporary arrays
//        A5LogicalZonotopeQueue a5 = InitializeA5LogicalZonotopeQueue(tempRAtask, tempRBtask, tempRCtask, &outStream, count);
//      //  A5PolyLogicalZonotope A5PolyZonotope(tempRAtask, tempRBtask, tempRCtask);
//
//
//        // Nested loops for RB and RC
//        for (int j = 0; j < L; j++) {
//            Helper::FillLastNBitsWithRow(tempRBtask, RBlength, AssumedBitstruthTableZonotope, j, noAssumedBits);
//
//            for (int k = 0; k < L; k++) {
//                Helper::FillLastNBitsWithRow(tempRCtask, RClength, AssumedBitstruthTableZonotope, k, noAssumedBits);
//                bool isValid = false;
//
//                //Helper::PrintRegisters(tempRAtask, tempRBtask, tempRCtask);
//                if (isExactPoly)
//                {
//                   // isValid = A5PolyZonotope.IsValidKey();
//                }
//                else
//                {
//                    // Explore all clocking branches as the clocking bits are uncertain
//                    isValid = IsValidKey(a5,'A');
//                    if (!isValid) isValid = IsValidKey(a5,'B');
//                    if (!isValid) isValid = IsValidKey(a5,'C');
//                    if (!isValid) isValid = IsValidKey(a5,'D');
//                    //    std::cout << "is valid = " << std::boolalpha << isValid << "\n" << std::endl;
//                }
//                    // If key is valid, add the combination to the validGuessConBag
//                if (isValid) {
//                    int* ptr = new int[3] { index, j, k };
//
//                    // int ptr[3];
//                    /* ptr[0] = index;
//                     ptr[1] = j;
//                     ptr[2] = k;*/
//
//                     // validGuessConBag.push_back(ptr);
//
//                   privateBags[tbb::this_task_arena::current_thread_index()].push_back(ptr);
//                }
//            }
//        }
//
//        delete[] tempRAtask;
//        delete[] tempRBtask;
//        delete[] tempRCtask;
//        });
//
//    // Merge private bags into the main bag
//    for (auto& privateBag : privateBags) {
//        validGuessConBag.insert(validGuessConBag.end(), privateBag.begin(), privateBag.end());
//    }
//    privateBags.clear();
//
//    //for (int i = 0; i < omp_get_num_threads(); i++) {
//    //    validGuessConBag.insert(validGuessConBag.end(), privateBags[i].begin(), privateBags[i].end());
//    //    privateBags[i].clear();  // Clear the private bag after merging
//    //}
//
//    // Merge private bags into the main bag
//   /* for (auto& privateBag : privateBags) {
//        validGuessConBag.insert(validGuessConBag.end(), privateBag.begin(), privateBag.end());
//    }*/
//
//   
//
//}
//
//

//
//
//int main()
//{
//    int a = 5;
//    
//    cudaDeviceSynchronize();
//        return 0;
//}
//
//
//
//
//
////int main()
////{
////    LightLogicalZonotope* RA = Helper::GenerateLogicalZonotopeRegister(RAlength);
////    LightLogicalZonotope* RB = Helper::GenerateLogicalZonotopeRegister(RBlength);
////    LightLogicalZonotope* RC = Helper::GenerateLogicalZonotopeRegister(RClength);
////
////    std::cout << "==============================================================\n";
////    std::cout << "             A5 Breaker using logicalZonotope !\n";
////    std::cout << "==============================================================\n";
////
////    test1<<<1, 1 >>>();
////    cudaDeviceSynchronize();
////    return 0;
////
////    // **  Running some test Cases
////    RunTestCases();
////    //Helper::A5StreamCalcultionTime(100);
////    //
////    std::vector<int*> validGuessConBag;
////
////    Initialization();
////   // A5LogicalZonotopeQueue::InitializeA5LogicalZonotopeQueue(&outStream, count);
////
////    // Start the timer
////    auto start = std::chrono::high_resolution_clock::now();
////    FindValidCompinations(validGuessConBag, noAssumedBits);
////
////    // Stop the timer
////    auto stop = std::chrono::high_resolution_clock::now();
////    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(stop - start);
////    std::cout << "Time taken by function: " << duration.count() << " milliseconds" << std::endl;
////
////    std::cout << "Total Number of Guesses: " << validGuessConBag.size() << std::endl;
////
////    std::sort(validGuessConBag.begin(), validGuessConBag.end(), Helper::compareIntArrays);
////
////    /*  for (const auto& guess : validGuessConBag) {
////          std::cout << "Valid Guess: {" << guess[0] << ", " << guess[1] << ", " << guess[2] << "}" << std::endl;
////      }*/
////
////
////      /****** Starting the Deep Mode*******/
////
////  //  InitializeStaticMembers();
////
////
////    //std::for_each( validGuessConBag.begin(), validGuessConBag.end(), [&](int* index) {
////    //#pragma omp parallel for num_threads(8)
////    //for (int it = 0; it < static_cast<int>(validGuessConBag.size()); ++it) {
////    //    int* index = validGuessConBag[it];
////    //    int i = index[0], j = index[1], k = index[2];
////
////    if (isExactPoly)
////    {
////        std::cout << std::endl  << "**********Operating in Exact Poly Mode*******" << std::endl;
////    }
////
////        // Use TBB for parallel processing
////  /*  tbb::parallel_for(tbb::blocked_range<size_t>(0, validGuessConBag.size()),
////        [&](const tbb::blocked_range<size_t>& r) {
////            for (size_t it = r.begin(); it != r.end(); ++it) {
////                int* index = validGuessConBag[it];
////                int i = index[0], j = index[1], k = index[2];*/
////    
////               int i = 0, j = 0, k = 1;
////
////                std::string indexText = "i = " + std::to_string(i) + ", j = " + std::to_string(j) + ", k = " + std::to_string(k);
////                std::cout << "\n[Main Thread] " << indexText << " Started  @  " << Helper::GetCurrentTime() << std::endl;
////
////                // Create temporary copies of RA, RB, RC
////                LightLogicalZonotope* tempRAtask = new LightLogicalZonotope[RAlength];
////                LightLogicalZonotope* tempRBtask = new LightLogicalZonotope[RBlength];
////                LightLogicalZonotope* tempRCtask = new LightLogicalZonotope[RClength];
////
////                // Copy values from RA, RB, RC to temporary arrays
////                std::copy(RA, RA + RAlength, tempRAtask);
////                std::copy(RB, RB + RBlength, tempRBtask);
////                std::copy(RC, RC + RClength, tempRCtask);
////                // Assuming FillLastNBitsWithRow is a function to fill the last N bits with a row from the truthTable
////                Helper::FillLastNBitsWithRow(tempRAtask, RAlength, AssumedBitstruthTableZonotope, i, noAssumedBits);
////                Helper::FillLastNBitsWithRow(tempRBtask, RBlength, AssumedBitstruthTableZonotope, j, noAssumedBits);
////                Helper::FillLastNBitsWithRow(tempRCtask, RClength, AssumedBitstruthTableZonotope, k, noAssumedBits);
////
////                bool key = false;
////                int RCInitialIndex = RAlength - noAssumedBits + 3;
////               finalStep(tempRAtask, tempRBtask, tempRCtask, RCInitialIndex);
////
////                /*
////
////                  if (isMixedMode)
////                      key = A5Breaker_ExactPoly_A5RFBZT_12_DeepModeLoop_A5Loop(tempRAtask.data(), tempRBtask.data(), tempRCtask.data(), indexText);
////                  else
////                      key = A5Breaker_LogicalZonotope_A5RFBZT_12_DeepModeLoop_A5Loop(tempRAtask.data(), tempRBtask.data(), tempRCtask.data(), indexText);
////                      */
////
////                std::cout << "\n[Main Thread] " << indexText << " THREAD FINISHED @  "<< Helper::GetCurrentTime() << std::endl;
////               
////                delete[] tempRAtask;
////                delete[] tempRBtask;
////                delete[] tempRCtask;
////
////           // }});
////
////
////
////
////    // A5LogicalZonotopeQueue::_outStream = &outStream;
////     //A5LogicalZonotopeQueue::_count = count;
////
////
////    return 0;
////}
////
////
////
////
////
////void RunTestCases()
////{
////    TestCases::TestAnd();
////    TestCases::TestOr();
////    TestCases::TestNot();
////   TestCases::testReverseQueueSt();
////
////
////    int n = 5;
////    // Generate and print the truth table
////    int* truthTable = Helper::GetTruthTable(n);
////   // Helper::PrintTruthTable(truthTable, n);
////    // Deallocate memory for the truth table
////    delete[] truthTable;
////    
////    // Generate and print the logical zonotope truth table
////    LightLogicalZonotope* truthTableZonotope = Helper::GetTruthTableZonotope(n);
////   // Helper::PrintTruthTableZonotope(truthTableZonotope, n);
////}
