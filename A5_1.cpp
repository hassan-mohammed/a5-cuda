#include <iostream>
#include <vector>
#include <chrono>
#include <algorithm>
#pragma once
const int RAlength = 19;
const int RBlength = 22;
const int RClength = 23;


class A5_1 {
public:
    static int* GenerateSequence(const int RA[], const int RB[], const int RC[], int count) {
       int* seq = new int[count];
        int index = 0;


        int RAcopy[RAlength];
        int RBcopy[RBlength];
        int RCcopy[RClength];

        std::copy(RA, RA + RAlength, RAcopy );
        std::copy(RB, RB + RBlength, RBcopy);
        std::copy(RC, RC + RClength, RCcopy);

        while (index < count) {
            int RA19 = RAcopy[18];
            int RB22 = RBcopy[21];
            int RC23 = RCcopy[22];
            int RA9 = RAcopy[8];
            int RB11 = RBcopy[10];
            int RC11 = RCcopy[10];

            int Max0 = 0;
            int Max1 = 0;

            if (RA9 == 1)
                Max1++;
            else
                Max0++;

            if (RB11 == 1)
                Max1++;
            else
                Max0++;

            if (RC11 == 1)
                Max1++;
            else
                Max0++;

            int CK = Max1 > Max0 ? 1 : 0;

            int tempA = RA19 ^ RAcopy[17];
            tempA ^= RAcopy[16];
            tempA ^= RAcopy[13];
            int tempB = RB22 ^ RBcopy[20];
            int tempC = RC23 ^ RCcopy[21];
            tempC ^= RCcopy[20];
            tempC ^= RCcopy[7];

            if (RA9 == CK) {
                for (int ind = 18; ind > 0; ind--) {
                    RAcopy[ind] = RAcopy[ind - 1];
                }
                RAcopy[0] = tempA;
            }

            if (RB11 == CK) {
                for (int ind = 21; ind > 0; ind--) {
                    RBcopy[ind] = RBcopy[ind - 1];
                }
                RBcopy[0] = tempB;
            }

            if (RC11 == CK) {
                for (int ind = 22; ind > 0; ind--) {
                    RCcopy[ind] = RCcopy[ind - 1];
                }
                RCcopy[0] = tempC;
            }

            int outA = RA19 ^ RB22;
            outA ^= RC23;
            seq[index] = outA;
            index++;
        }

        return seq;
    }
};
