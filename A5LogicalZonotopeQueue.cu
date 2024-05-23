#define MAX_STACK_SIZE 64
#define CountConst 64


#include <iostream>
#include <array>
#include <vector>
#include <unordered_map>
#include "Helper.cpp"
#include "device_launch_parameters.h"
#include <cuda_runtime.h>
#pragma once

__device__  __constant__ const int d_RAlength = 19;
__device__  __constant__ const int d_RBlength = 22;
__device__  __constant__ const int d_RClength = 23;

struct StackItem {
    int  countCurr;
    int  RAind;
    int  RBind;
    int  RCind;
    bool clkCondArray[4];
};

struct A5LogicalZonotopeQueue {

    int countCurr;

    LightLogicalZonotope* _RAMain;
    LightLogicalZonotope* _RBMain;
    LightLogicalZonotope* _RCMain;
    bool* clkCondArray;

    LightLogicalZonotope _tempRA[d_RAlength + CountConst];
    LightLogicalZonotope _tempRB[d_RAlength + CountConst];
    LightLogicalZonotope _tempRC[d_RClength + CountConst];

    StackItem _stack[MAX_STACK_SIZE];
    StackItem* dctItemPointer;

    int stackIndex;

    bool clkCondA = false, clkCondB = false, clkCondC = false, clkCondD = false;



};


static __device__ __host__  void XorDevice(const LightLogicalZonotope& zonotope1, const LightLogicalZonotope& zonotope2, const LightLogicalZonotope& zonotope3, LightLogicalZonotope& zonotopeOut) {
    if (zonotope3.Generator != 0)
        zonotopeOut.Generator = 1;
    else if (zonotope2.Generator != 0)
        zonotopeOut.Generator = 1;
    else if (zonotope1.Generator != 0)
        zonotopeOut.Generator = 1;
    else {
        zonotopeOut.Generator = 0;
        zonotopeOut.Point = zonotope1.Point ^ zonotope2.Point ^ zonotope3.Point;
    }
}

__device__ __host__ static bool IsValidKey(A5LogicalZonotopeQueue& A5LZQueue, char clkCond);
__device__ __host__ static void ClkRegistersNew(A5LogicalZonotopeQueue& A5LZQueue, char clkCond, int& RAind, int& RBind, int& RCind) ;
__device__ __host__ static void MajorityFunction(A5LogicalZonotopeQueue& A5LZQueue, int& RAind, int& RBind, int& RCind)                 ;
__device__ __host__ static void AddNewItem(A5LogicalZonotopeQueue& A5LZQueue, int& countCurr, int&  RAind, int& RBind, int& RCind)        ;


static __device__   LightLogicalZonotope uncertainPoint = LightLogicalZonotope{ 0, 1 };
static __device__   LightLogicalZonotope oneCertainPoint = LightLogicalZonotope{ 1, 0 };
static __device__   LightLogicalZonotope zeroCertainPoint = LightLogicalZonotope{ 0, 0 };
const static __device__    int* _outStream;
static __device__   int _count;



    // Assuming FindA5KeyLightZT class is defined appropriately
__device__ __host__ static void InitializeA5LogicalZonotopeQueue(A5LogicalZonotopeQueue* A5LZQueue, LightLogicalZonotope* RA, LightLogicalZonotope* RB, LightLogicalZonotope* RC, const int* outStream, int count) {
        _outStream = outStream;
       _count = count;
       
       A5LZQueue->_RAMain = RA;
       A5LZQueue->_RBMain = RB;
       A5LZQueue->_RCMain = RC;



    }

   
__device__ __host__  static bool IsValidKey(A5LogicalZonotopeQueue& A5LZQueue, char clkCond) {
        A5LZQueue.stackIndex = 0;
        int countCurr = _count;
        LightLogicalZonotope  outA;


        int RAind, RBind, RCind;

        RAind = RBind = RCind = _count;

        //TODO is there's a better and faster way to do that instead of for loops
        /*std::copy(A5LZQueue._RAMain, A5LZQueue._RAMain + RAlength, A5LZQueue._tempRA + _count);
        std::copy(A5LZQueue._RBMain, A5LZQueue._RBMain + RBlength, A5LZQueue._tempRB + _count);
        std::copy(A5LZQueue._RCMain, A5LZQueue._RCMain + RClength, A5LZQueue._tempRC + _count);*/
        int i = 0;

        for (; i < d_RAlength; ++i) {
            A5LZQueue._tempRA[i + _count] = A5LZQueue._RAMain[i];
            A5LZQueue._tempRB[i + _count] = A5LZQueue._RBMain[i];
            A5LZQueue._tempRC[i + _count] = A5LZQueue._RCMain[i];
        }

        for (i = d_RAlength; i < d_RBlength; ++i) {
            A5LZQueue._tempRB[i + _count] = A5LZQueue._RBMain[i];
            A5LZQueue._tempRC[i + _count] = A5LZQueue._RCMain[i];
        }

        for (i = d_RBlength; i < d_RClength; ++i) {
            A5LZQueue._tempRC[i + _count] = A5LZQueue._RCMain[i];
        }
        ///////////// first round ////////////

        // calculating the output
        outA.Generator = 1;
        XorDevice(A5LZQueue._tempRA[RAind + 18], A5LZQueue._tempRB[RBind + 21], A5LZQueue._tempRC[RCind + 22], outA);
        if (!(outA.Point == _outStream[_count - countCurr]))
            return false;

        // calculating the feedback bits
        //CalculateFeedbackBits();
        // Clock the registers


        ClkRegistersNew(A5LZQueue, clkCond, RAind, RBind, RCind);

        //Helper.PrintRegisters( A5LZQueue._tempRA,  A5LZQueue._tempRB,  A5LZQueue._tempRC);

        ///////////// second round ////////////
        countCurr--;
        // calculating the output
        XorDevice(A5LZQueue._tempRA[RAind + 18], A5LZQueue._tempRB[RBind + 21], A5LZQueue._tempRC[RCind + 22], outA);
        if (!(outA.Generator != 0 || outA.Point == _outStream[_count - countCurr]))
            return false;

        // calculate the majority bits for all registers using majority function
        //clkCondArray = MajorityFunction();

        AddNewItem(A5LZQueue, countCurr, RAind, RBind, RCind);
        // clkCondArray = _stack[stackIndex].Item5;
        while (countCurr > 1) {
            countCurr--;
            A5LZQueue.clkCondArray = &A5LZQueue._stack[A5LZQueue.stackIndex].clkCondArray[0];
            if (A5LZQueue.clkCondArray[0] == true) {
                A5LZQueue.clkCondArray[0] = false;
                clkCond = 'A';
                XorDevice(A5LZQueue._tempRA[RAind + 17], A5LZQueue._tempRB[RBind + 20], A5LZQueue._tempRC[RCind + 21], outA);
                if (outA.Generator != 0 || outA.Point == _outStream[_count - countCurr]) {
                    ClkRegistersNew(A5LZQueue, clkCond, RAind, RBind, RCind);
                    AddNewItem(A5LZQueue, countCurr, RAind, RBind, RCind);
                    continue;
                }
            }

            if (A5LZQueue.clkCondArray[1] == true) {
                A5LZQueue.clkCondArray[1] = false;
                clkCond = 'B';
                XorDevice(A5LZQueue._tempRA[RAind + 17], A5LZQueue._tempRB[RBind + 20], A5LZQueue._tempRC[RCind + 22], outA);
                if (outA.Generator != 0 || outA.Point == _outStream[_count - countCurr]) {
                    ClkRegistersNew(A5LZQueue, clkCond, RAind, RBind, RCind);
                    AddNewItem(A5LZQueue, countCurr, RAind, RBind, RCind);
                    continue;
                }
            }
            if (A5LZQueue.clkCondArray[2] == true) {
                A5LZQueue.clkCondArray[2] = false;
                clkCond = 'C';

                XorDevice(A5LZQueue._tempRA[RAind + 17], A5LZQueue._tempRB[RBind + 21], A5LZQueue._tempRC[RCind + 21], outA);

                if (outA.Generator != 0 || outA.Point == _outStream[_count - countCurr]) {
                    ClkRegistersNew(A5LZQueue, clkCond, RAind, RBind, RCind);
                    AddNewItem(A5LZQueue, countCurr, RAind, RBind, RCind);
                    continue;
                }
            }
            if (A5LZQueue.clkCondArray[3] == true) {
                A5LZQueue.clkCondArray[3] = false;
                clkCond = 'D';

                XorDevice(A5LZQueue._tempRA[RAind + 18], A5LZQueue._tempRB[RBind + 20], A5LZQueue._tempRC[RCind + 21], outA);
                if (outA.Generator != 0 || outA.Point == _outStream[_count - countCurr]) {
                    ClkRegistersNew(A5LZQueue, clkCond, RAind, RBind, RCind);
                    AddNewItem(A5LZQueue, countCurr, RAind, RBind, RCind);
                    continue;

                }
            }
            A5LZQueue.stackIndex--;
            if (A5LZQueue.stackIndex == 0) {
                return false;
            }
            // retrieve elements from the stack at key =  A5LZQueue.stackIndex
           // std::tie(RAind, RBind, RCind, countCurr, A5LZQueue.clkCondArray) = A5LZQueue._stack[A5LZQueue.stackIndex];

            //StackItem& stackItem = A5LZQueue._stack[A5LZQueue.stackIndex];
            RAind = A5LZQueue._stack[A5LZQueue.stackIndex].RAind;
            RBind = A5LZQueue._stack[A5LZQueue.stackIndex].RBind;
            RCind = A5LZQueue._stack[A5LZQueue.stackIndex].RCind;
            countCurr = A5LZQueue._stack[A5LZQueue.stackIndex].countCurr;
            A5LZQueue.clkCondArray = &A5LZQueue._stack[A5LZQueue.stackIndex].clkCondArray[0];
        }

        return true;
    }

__device__ __host__ __inline__ static void ClkRegistersNew(A5LogicalZonotopeQueue& A5LZQueue, char clkCond, int& RAind, int& RBind, int& RCind) {
        int FeedbackPoint;
        if (clkCond == 'A' || clkCond == 'B' || clkCond == 'C') {
            if (A5LZQueue._tempRA[RAind + 13].Generator == 0 && A5LZQueue._tempRA[RAind + 16].Generator == 0 &&
                A5LZQueue._tempRA[RAind + 17].Generator == 0 && A5LZQueue._tempRA[RAind + 18].Generator == 0) {
                FeedbackPoint = A5LZQueue._tempRA[RAind + 13].Point ^ A5LZQueue._tempRA[RAind + 16].Point ^
                    A5LZQueue._tempRA[RAind + 17].Point ^ A5LZQueue._tempRA[RAind + 18].Point;
                // std::copy( A5LZQueue._tempRA + 1,  A5LZQueue._tempRA + RAlength,  A5LZQueue._tempRA);
                A5LZQueue._tempRA[RAind - 1] = (FeedbackPoint == 1) ? oneCertainPoint : zeroCertainPoint;
            }
            else {
                // std::copy( A5LZQueue._tempRA + 1,  A5LZQueue._tempRA + RAlength,  A5LZQueue._tempRA);
                A5LZQueue._tempRA[RAind - 1] = uncertainPoint;
            }
            RAind--;
        }

        if (clkCond == 'A' || clkCond == 'B' || clkCond == 'D') {
            if (A5LZQueue._tempRB[RBind + 20].Generator == 0 && A5LZQueue._tempRB[RBind + 21].Generator == 0) {
                FeedbackPoint = A5LZQueue._tempRB[RBind + 20].Point ^ A5LZQueue._tempRB[RBind + 21].Point;
                // std::copy( A5LZQueue._tempRB + 1,  A5LZQueue._tempRB + RBlength,  A5LZQueue._tempRB);
                A5LZQueue._tempRB[RBind - 1] = (FeedbackPoint == 1) ? oneCertainPoint : zeroCertainPoint;
            }
            else {
                // std::copy( A5LZQueue._tempRB + 1,  A5LZQueue._tempRB + RBlength,  A5LZQueue._tempRB);
                A5LZQueue._tempRB[RBind - 1] = uncertainPoint;
            }
            RBind--;
        }

        if (clkCond == 'A' || clkCond == 'C' || clkCond == 'D') {
            if (A5LZQueue._tempRC[RCind + 7].Generator == 0 && A5LZQueue._tempRC[RCind + 20].Generator == 0 &&
                A5LZQueue._tempRC[RCind + 21].Generator == 0 && A5LZQueue._tempRC[RCind + 22].Generator == 0) {
                FeedbackPoint = A5LZQueue._tempRC[RCind + 7].Point ^ A5LZQueue._tempRC[RCind + 20].Point ^
                    A5LZQueue._tempRC[RCind + 21].Point ^ A5LZQueue._tempRC[RCind + 22].Point;
                // std::copy( A5LZQueue._tempRC + 1,  A5LZQueue._tempRC + RClength,  A5LZQueue._tempRC);
                A5LZQueue._tempRC[RCind - 1] = (FeedbackPoint == 1) ? oneCertainPoint : zeroCertainPoint;
            }
            else {
                // std::copy( A5LZQueue._tempRC + 1,  A5LZQueue._tempRC + RClength,  A5LZQueue._tempRC);
                A5LZQueue._tempRC[RCind - 1] = uncertainPoint;
            }
            RCind--;
        }
    }

__device__ __host__ static void MajorityFunction(A5LogicalZonotopeQueue& A5LZQueue, int& RAind, int& RBind, int& RCind) {
        LightLogicalZonotope _RA8 = A5LZQueue._tempRA[RAind + 8];
        LightLogicalZonotope _RB10 = A5LZQueue._tempRB[RBind + 10];
        LightLogicalZonotope _RC10 = A5LZQueue._tempRC[RCind + 10];

         A5LZQueue.clkCondA = false;
         A5LZQueue.clkCondB = false;
         A5LZQueue.clkCondC = false;
         A5LZQueue.clkCondD = false;

        // Check if RA9, RB11, RC11 generator property is empty or not
        if (_RA8.Generator == 0 && _RB10.Generator == 0 && _RC10.Generator == 0) {
            // If empty, then check if RA9, RB11, RC11 points are equal or not
            if (_RA8.Point == _RB10.Point && _RB10.Point == _RC10.Point) {
                A5LZQueue.clkCondA = true;
            }
            else if (_RA8.Point == _RB10.Point) {
                A5LZQueue.clkCondB = true;
            }
            else if (_RA8.Point == _RC10.Point) {
                A5LZQueue.clkCondC = true;
            }
            else if (_RB10.Point == _RC10.Point) {
                A5LZQueue.clkCondD = true;
            }
        }
        else if (_RA8.Generator == 0 && _RB10.Generator == 0) {
            if (_RA8.Point == _RB10.Point) {
                A5LZQueue.clkCondA = true;
                A5LZQueue.clkCondB = true;
            }
            else {
                A5LZQueue.clkCondC = true;
                A5LZQueue.clkCondD = true;
            }
        }
        else if (_RA8.Generator == 0 && _RC10.Generator == 0) {
            if (_RA8.Point == _RC10.Point) {
                A5LZQueue.clkCondA = true;
                A5LZQueue.clkCondC = true;
            }
            else {
                A5LZQueue.clkCondB = true;
                A5LZQueue.clkCondD = true;
            }
        }
        // Check the RC11 and RB11 generators
        else if (_RB10.Generator == 0 && _RC10.Generator == 0) {
            if (_RB10.Point == _RC10.Point) {
                A5LZQueue.clkCondA = true;
                A5LZQueue.clkCondD = true;
            }
            else {
                A5LZQueue.clkCondB = true;
                A5LZQueue.clkCondC = true;
            }
        }
        else {
            A5LZQueue.clkCondA = true;
            A5LZQueue.clkCondB = true;
            A5LZQueue.clkCondC = true;
            A5LZQueue.clkCondD = true;
        }
        A5LZQueue.clkCondArray = &A5LZQueue.dctItemPointer->clkCondArray[0];

        A5LZQueue.clkCondArray[0] = A5LZQueue.clkCondA;
        A5LZQueue.clkCondArray[1] = A5LZQueue.clkCondB;
        A5LZQueue.clkCondArray[2] = A5LZQueue.clkCondC;
        A5LZQueue.clkCondArray[3] = A5LZQueue.clkCondD;
    }



static __device__ __host__  void AddNewItem(A5LogicalZonotopeQueue& A5LZQueue, int& countCurr,  int& RAind, int& RBind, int& RCind) {
        A5LZQueue.stackIndex++;
        // A5LZQueue.dctItem = A5LZQueue._stack[A5LZQueue.stackIndex];
        A5LZQueue.dctItemPointer = &A5LZQueue._stack[A5LZQueue.stackIndex];

        A5LZQueue.dctItemPointer->countCurr = countCurr;
        A5LZQueue.dctItemPointer->RAind = RAind;
        A5LZQueue.dctItemPointer->RBind = RBind;
        A5LZQueue.dctItemPointer->RCind = RCind;

        //  A5LZQueue.clkCondArray = A5LZQueue.dctItem.clkCondArray;
        MajorityFunction(A5LZQueue, RAind, RBind, RCind);
    }



__device__ __host__ static void MajorityFunction(LightLogicalZonotope& RA8, LightLogicalZonotope& RB10, LightLogicalZonotope& RC10, bool(&clkCondArray)[4])
{
    clkCondArray[0] = false;
    clkCondArray[1] = false;
    clkCondArray[2] = false;
    clkCondArray[3] = false;

    // Check if RA9, RB11, RC11 generator property is empty or not
    if (RA8.Generator == 0 && RB10.Generator == 0 && RC10.Generator == 0)
    {
        // If empty, then check if RA9, RB11, RC11 points are equal or not
        if (RA8.Point == RB10.Point && RB10.Point == RC10.Point) {
            clkCondArray[0] = true;
        }
        else if (RA8.Point == RB10.Point) {
            clkCondArray[1] = true;
        }
        else if (RA8.Point == RC10.Point) {
            clkCondArray[2] = true;
        }
        else if (RB10.Point == RC10.Point) {
            clkCondArray[3] = true;
        }
    }
    else if (RA8.Generator == 0 && RB10.Generator == 0) {
        if (RA8.Point == RB10.Point) {
            clkCondArray[0] = true;
            clkCondArray[1] = true;
        }
        else {
            clkCondArray[2] = true;
            clkCondArray[3] = true;
        }
    }
    else if (RA8.Generator == 0 && RC10.Generator == 0) {
        if (RA8.Point == RC10.Point) {
            clkCondArray[0] = true;
            clkCondArray[2] = true;
        }
        else {
            clkCondArray[1] = true;
            clkCondArray[3] = true;
        }
    }
    // Check the RC11 and RB11 generators
    else if (RB10.Generator == 0 && RC10.Generator == 0) {
        if (RB10.Point == RC10.Point) {
            clkCondArray[0] = true;
            clkCondArray[3] = true;
        }
        else {
            clkCondArray[1] = true;
            clkCondArray[2] = true;
        }
    }
    else {
        clkCondArray[0] = true;
        clkCondArray[1] = true;
        clkCondArray[2] = true;
        clkCondArray[3] = true;
    }



}

    // TODO: create a Destructor for the  struct
    //~A5LogicalZonotopeQueue() {
    //    for (int i = 0; i < _count; i++) {
    //        delete[] std::get<4>(_stack[i]);  // Free the bool array
    //    }
    //    delete[]  A5LZQueue._tempRA;  // Free the LightLogicalZonotope arrays
    //    delete[]  A5LZQueue._tempRB;
    //    delete[]  A5LZQueue._tempRC;
    // 
    // 
    //}



