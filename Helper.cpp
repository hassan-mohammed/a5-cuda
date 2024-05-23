#pragma once

#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <chrono>
#include <ctime>
#include <iomanip>
#include "A5_1.cpp"
#include "LightLogicalZonotope.cpp"
#include <tbb/tbb.h>
#pragma once

static int * outStream;
static int noAssumedBits, deepNoAssumedBits, noSegmants;
static int count;
static bool isExactPoly;
static LightLogicalZonotope zeroPoint{ 0,0 };
static LightLogicalZonotope onePoint{ 1,0 };
class Helper {
public:
    static std::vector<int> GenerateRandomRegister(int length) {
        // Your implementation for generating a random register
        // Replace this with your actual implementation
        return std::vector<int>(length, 0);
    }

    static void PrintRegisters(const std::string& RA, const std::string& RB, const std::string& RC)
    {
        std::cout << "RA:         " << RA << std::endl;
        std::cout << "RB:   " << RB << std::endl;
        std::cout << "RC: " << RC << std::endl;
    }
    static void PrintRegisters(const std::vector<int>& RA, const std::vector<int>& RB, const std::vector<int>& RC) {
        std::cout << "RA:         ";
        for (const auto& element : RA) {
            std::cout << element << " ";
        }
        std::cout << std::endl;

        std::cout << "RB:   ";
        for (const auto& element : RB) {
            std::cout << element << " ";
        }
        std::cout << std::endl;

        std::cout << "RC: ";
        for (const auto& element : RC) {
            std::cout << element << " ";
        }
        std::cout << std::endl;
    }
   
    static void PrintRegisters(const int RA[], const int RB[], const int RC[]) {
        std::cout << "RA = {             ";
        for (int i = 0; i < RAlength; ++i) {
            std::cout << RA[i] << ", ";
        }
        std::cout << std::endl;

        std::cout << "RB = {    ";
        for (int i = 0; i < RBlength; ++i) {
            std::cout << RB[i] << ", ";
        }
        std::cout << std::endl;

        std::cout << "RC = { ";
        for (int i = 0; i < RClength; ++i) {
            std::cout << RC[i] << ", ";
        }
        std::cout << std::endl << std::endl;
    }
   
    static void PrintRegisters(const LightLogicalZonotope* RA, const LightLogicalZonotope* RB,  const LightLogicalZonotope* RC) {
        std::ostringstream RAregister, RBregister, RCregister;
        RAregister << "RA = {             ";
        for (int i = 0; i < RAlength; ++i) {
            if (RA[i].Generator == 0) {
                RAregister << RA[i].Point << ", ";
            }
            else {
                RAregister << "Z, ";
            }
        }
        RAregister << "}";

        RBregister << "RB = {    ";
        for (int i = 0; i < RBlength; ++i) {
            if (RB[i].Generator == 0) {
                RBregister << RB[i].Point << ", ";
            }
            else {
                RBregister << "Z, ";
            }
        }
        RBregister << "}";

        RCregister << "RC = { ";
        for (int i = 0; i < RClength; ++i) {
            if (RC[i].Generator == 0) {
                RCregister << RC[i].Point << ", ";
            }
            else {
                RCregister << "Z, ";
            }
        }
        RCregister << "}";

        std::ostringstream keyFound;
        keyFound << RAregister.str() << "\n" << RBregister.str() << "\n" << RCregister.str();

        std::cout << keyFound.str() << std::endl << std::endl;
    }




    static void PrintCurrentTime()
    {
        // Get the current time point
        auto currentTime = std::chrono::system_clock::now();

        // Convert the time point to a time_t object
        std::time_t currentTime_t;
        time(&currentTime_t);

        // Convert the time_t to a tm structure
        std::tm currentTimeInfo;
        localtime_s(&currentTimeInfo, &currentTime_t);

        // Print the current date and time
        std::cout << "Current Date and Time: ";
        std::cout << (currentTimeInfo.tm_year + 1900) << '-'
            << (currentTimeInfo.tm_mon + 1) << '-'
            << currentTimeInfo.tm_mday << ' '
            << currentTimeInfo.tm_hour << ':'
            << currentTimeInfo.tm_min << ':'
            << currentTimeInfo.tm_sec << std::endl;

    }
    static std::string GetCurrentTime() {
        // Get the current time point
        auto currentTime = std::chrono::system_clock::now();

        // Convert the time point to a time_t object
        std::time_t currentTime_t;
        time(&currentTime_t);

        // Convert the time_t to a tm structure
        std::tm currentTimeInfo;
        localtime_s(&currentTimeInfo, &currentTime_t);

        // Create a stringstream to format the date and time
        std::stringstream ss;
        ss << std::put_time(&currentTimeInfo, "%Y-%m-%d %H:%M:%S");

        // Return the formatted date and time as a string
        return ss.str();
    }


    static void A5StreamCalcultionTime(int count)
    {
        // Initialize RA, RB, RC with the provided C# code
       int RA[] = { 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
       int RB[] = { 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 };
       int RC[] = { 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1 };

        // Start the timer
        auto start = std::chrono::high_resolution_clock::now();

        // Call the function 
       int * outStream = A5_1::GenerateSequence(RA, RB, RC, count);

        // Stop the timer
        auto stop = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::microseconds>(stop - start);

        // Print the result
        std::cout << "Generated Sequence:" << std::endl;
        for (size_t i = 0; i < count; i++)
        {
            std::cout << outStream[i] << ",";
        }
     
        std::cout << std::endl;

        std::cout << "Time taken by function: " << duration.count() << " microseconds" << std::endl;
    }


    // Function to get the truth table with the specified number of bits
    static int* GetTruthTable(int n) {
        int L = static_cast<int>(std::pow(2, n));

        // Allocate memory for a single contiguous array
        int* truthTable = new int[L * n];

        // Fill in the truth table
        for (int i = 0; i < L; ++i) {
            for (int j = 0; j < n; ++j) {
                truthTable[i * n + (n - j - 1)] = (i >> j) & 1;
            }
        }

        return truthTable;
    }


    // Function to print a truth table
    static void PrintTruthTable(int* truthTable, int n) {
        int L = static_cast<int>(std::pow(2, n));

        for (int i = 0; i < L; ++i) {
            for (int j = 0; j < n; ++j) {
                std::cout << truthTable[i * n + j] << ' ';
            }
            std::cout << std::endl;
        }
    }





    // Function to get the truth table zonotope with the specified number of bits
    static LightLogicalZonotope* GetTruthTableZonotope(int noBits)//, int& length) 
    {
        int L = static_cast<int>(std::pow(2, noBits));

        // Get the truth table
        int* truthTable = new int[L * noBits];
        truthTable = GetTruthTable(noBits);

        // Create the truth table zonotope as a dynamic array
        LightLogicalZonotope* truthTableZonotope = new LightLogicalZonotope[L * noBits];
       // length = L * noBits;

        for (int i = 0; i < L; ++i) {
            for (int j = 0; j < noBits; ++j) {
                truthTableZonotope[i * noBits + j] = (truthTable[i * noBits + j] == 0) ? zeroPoint : onePoint;
            }
        }

        // Deallocate memory for the truth table
        delete[] truthTable;

        return truthTableZonotope;
    }

    // Function to print the truth table zonotope
    static  void PrintTruthTableZonotope(const LightLogicalZonotope* truthTableZonotope, int noBits) {
        int L = static_cast<int>(std::pow(2, noBits));

        for (int i = 0; i < L; ++i) {
            for (int j = 0; j < noBits; ++j) {
                std::cout << "(" << truthTableZonotope[i * noBits + j].Point << ", " << truthTableZonotope[i * noBits + j].Generator << ") ";
            }
            std::cout << std::endl;
        }
    }

   static void FillLastNBitsWithRow(LightLogicalZonotope* reg, const int regLength, const LightLogicalZonotope* truthTableZonotope, int rowNo, int noBits) {
        int startIndex = regLength - noBits;

        for (int i = 0; i < noBits; i++) {
            reg[startIndex+ i] = truthTableZonotope[rowNo*noBits + i];  //TODO here we assume that we just want to point to this point
        }
    }


   static void FillNBitsWithRow(LightLogicalZonotope* array, int startIndex,  LightLogicalZonotope* row, int rowIndex, int noElements) {
       for (int i = 0; i < noElements; i++) {
           array[startIndex + i] = row[rowIndex + i];
       }
   }

  static LightLogicalZonotope* GenerateLogicalZonotopeRegister(int length) {
       LightLogicalZonotope* reg = new LightLogicalZonotope[length];

       for (int i = 0; i < length; i++) {
           reg[i] = LightLogicalZonotope{0, 1}; 
       }

       return reg;
   }
  static LightLogicalZonotope* GenerateLogicalZonotopeRegister(LightLogicalZonotope* reg, int length) {
      for (int i = 0; i < length; i++) {
          reg[i] = LightLogicalZonotope{ 0, 1 };
      }

      return reg;
  }

  static bool compareIntArrays(const int* arr1, const int* arr2) {
      // Compare based on the first element
      if (arr1[0] != arr2[0])
          return arr1[0] < arr2[0];
      // If the first elements are equal, compare based on the second element
      if (arr1[1] != arr2[1])
          return arr1[1] < arr2[1];
      // If both the first and second elements are equal, compare based on the third element
      return arr1[2] < arr2[2];
  }


    //static bool ParseOld(const std::string& filePath, std::vector<int>& RA, std::vector<int>& RB, std::vector<int>& RC) {
    //    std::ifstream configFile(filePath);
    //    if (!configFile.is_open()) {
    //        std::cerr << "Error opening configuration file." << std::endl;
    //        return false;
    //    }

    //    std::string line;
    //    std::stringstream xmlContent;
    //    while (std::getline(configFile, line)) {
    //        xmlContent << line;
    //    }

    //    // Parse configuration data
    //    // Replace this with your actual XML parsing logic
    //    // Example parsing logic:
    //    RA = ParseIntArray(xmlContent, "RATest");
    //    RB = ParseIntArray(xmlContent, "RBTest");
    //    RC = ParseIntArray(xmlContent, "RCTest");

    //    return true;
    //}


    static void ParseConfigFile(const char* filename, int RA[], int RB[], int RC[])
    {

        std::string RAstr, RBstr, RCstr;

        bool useTestingKey = false, useKnownRandom = false;

        std::ifstream file(filename);
        std::stringstream buffer;
        buffer << file.rdbuf();
        std::string xmlContent = buffer.str();

        // Find count
        size_t countPos = xmlContent.find("<add key=\"count\" value=\"");
        if (countPos != std::string::npos) {
            countPos += sizeof("<add key=\"count\" value=\"") - 1;
            size_t countEnd = xmlContent.find("\"", countPos);
            count = std::stoi(xmlContent.substr(countPos, countEnd - countPos));
        }

        // Find noAssumedBits
        size_t noAssumedBitsPos = xmlContent.find("<add key=\"noAssumedBits\" value=\"");
        if (noAssumedBitsPos != std::string::npos) {
            noAssumedBitsPos += sizeof("<add key=\"noAssumedBits\" value=\"") - 1;
            size_t noAssumedBitsEnd = xmlContent.find("\"", noAssumedBitsPos);
            noAssumedBits = std::stoi(xmlContent.substr(noAssumedBitsPos, noAssumedBitsEnd - noAssumedBitsPos));
        }
        // Find deepNoAssumedBits
        size_t deepNoAssumedBitsPos = xmlContent.find("<add key=\"deepNoAssumedBits\" value=\"");
        if (deepNoAssumedBitsPos != std::string::npos) {
            deepNoAssumedBitsPos += sizeof("<add key=\"deepNoAssumedBits\" value=\"") - 1;
            size_t deepNoAssumedBitsEnd = xmlContent.find("\"", deepNoAssumedBitsPos);
            deepNoAssumedBits = std::stoi(xmlContent.substr(deepNoAssumedBitsPos, deepNoAssumedBitsEnd - deepNoAssumedBitsPos));
        }

        // Find noSegmants
        size_t noSegmantsPos = xmlContent.find("<add key=\"noSegmants\" value=\"");
        if (noSegmantsPos != std::string::npos) {
            noSegmantsPos += sizeof("<add key=\"noSegmants\" value=\"") - 1;
            size_t noSegmantsEnd = xmlContent.find("\"", noSegmantsPos);
            noSegmants = std::stoi(xmlContent.substr(noSegmantsPos, noSegmantsEnd - noSegmantsPos));
        }


        // Find isMixMode
        size_t isMixModePos = xmlContent.find("<add key=\"isExactPoly\" value=\"");
        if (isMixModePos != std::string::npos) {
            isMixModePos += sizeof("<add key=\"isExactPoly\" value=\"") - 1;
            size_t isMixModeEnd = xmlContent.find("\"", isMixModePos);
            isExactPoly = (xmlContent.substr(isMixModePos, isMixModeEnd - isMixModePos) == "true");
        }

        // Find useTestingKey
        size_t useTestingKeyPos = xmlContent.find("<add key=\"useTestingKey\" value=\"");
        if (useTestingKeyPos != std::string::npos) {
            useTestingKeyPos += sizeof("<add key=\"useTestingKey\" value=\"") - 1;
            size_t useTestingKeyEnd = xmlContent.find("\"", useTestingKeyPos);
            useTestingKey = (xmlContent.substr(useTestingKeyPos, useTestingKeyEnd - useTestingKeyPos) == "true");
        }

        // Find useKnownRandom
        size_t useKnownRandomPos = xmlContent.find("<add key=\"useKnownRandom\" value=\"");
        if (useKnownRandomPos != std::string::npos) {
            useKnownRandomPos += sizeof("<add key=\"useKnownRandom\" value=\"") - 1;
            size_t useKnownRandomEnd = xmlContent.find("\"", useKnownRandomPos);
            useKnownRandom = (xmlContent.substr(useKnownRandomPos, useKnownRandomEnd - useKnownRandomPos) == "true");
        }

        if (useTestingKey)
        {
            // Find RATest
            size_t RATestPos = xmlContent.find("<add key=\"RATest\" value=\"");
            if (RATestPos != std::string::npos) {
                RATestPos += sizeof("<add key=\"RATest\" value=\"") - 1;
                size_t RATestEnd = xmlContent.find("\"", RATestPos);
                RAstr = xmlContent.substr(RATestPos, RATestEnd - RATestPos);
            }

            // Find RBTest
            size_t RBTestPos = xmlContent.find("<add key=\"RBTest\" value=\"");
            if (RBTestPos != std::string::npos) {
                RBTestPos += sizeof("<add key=\"RBTest\" value=\"") - 1;
                size_t RBTestEnd = xmlContent.find("\"", RBTestPos);
                RBstr = xmlContent.substr(RBTestPos, RBTestEnd - RBTestPos);
            }

            // Find RCTest
            size_t RCTestPos = xmlContent.find("<add key=\"RCTest\" value=\"");
            if (RCTestPos != std::string::npos) {
                RCTestPos += sizeof("<add key=\"RCTest\" value=\"") - 1;
                size_t RCTestEnd = xmlContent.find("\"", RCTestPos);
                RCstr = xmlContent.substr(RCTestPos, RCTestEnd - RCTestPos);
            }
        }
        else if (useKnownRandom)
        {

            // Find RAKnown
            size_t RAKnownPos = xmlContent.find("<add key=\"RAKnown\" value=\"");
            if (RAKnownPos != std::string::npos) {
                RAKnownPos += sizeof("<add key=\"RAKnown\" value=\"") - 1;
                size_t RAKnownEnd = xmlContent.find("\"", RAKnownPos);
                RAstr = xmlContent.substr(RAKnownPos, RAKnownEnd - RAKnownPos);
            }

            // Find RBKnown
            size_t RBKnownPos = xmlContent.find("<add key=\"RBKnown\" value=\"");
            if (RBKnownPos != std::string::npos) {
                RBKnownPos += sizeof("<add key=\"RBKnown\" value=\"") - 1;
                size_t RBKnownEnd = xmlContent.find("\"", RBKnownPos);
                RBstr = xmlContent.substr(RBKnownPos, RBKnownEnd - RBKnownPos);
            }

            // Find RCKnown
            size_t RCKnownPos = xmlContent.find("<add key=\"RCKnown\" value=\"");
            if (RCKnownPos != std::string::npos) {
                RCKnownPos += sizeof("<add key=\"RCKnown\" value=\"") - 1;
                size_t RCKnownEnd = xmlContent.find("\"", RCKnownPos);
                RCstr = xmlContent.substr(RCKnownPos, RCKnownEnd - RCKnownPos);
            }
        }

        stringToArray(RAstr, RA, RAlength);
        stringToArray(RBstr, RB, RBlength);
        stringToArray(RCstr, RC, RClength);


    }


    static void printCurrentDateTime() {
        while (true) {
            // Get the current time
            auto now = std::chrono::system_clock::now();
            std::time_t now_time = std::chrono::system_clock::to_time_t(now);

            // Format the time to a readable format
            std::tm* now_tm = std::localtime(&now_time);
            std::ostringstream oss;
            oss << std::put_time(now_tm, "%Y-%m-%d %H:%M:%S");
            std::string time_str = oss.str();

            // Print the formatted time
            std::cout << "Current Date and Time: " << time_str << std::endl;

            // Sleep for 10 minutes
            std::this_thread::sleep_for(std::chrono::minutes(1));
        }
    }

private:
    /*static std::vector<int> ParseIntArray(std::stringstream& xmlContent, const std::string& key) {
        std::vector<int> result;
        std::string searchString = "<add key=\"" + key + "\" value=\"";
        size_t pos = xmlContent.str().find(searchString);
        if (pos != std::string::npos) {
            pos += searchString.length();
            size_t endPos = xmlContent.str().find("\"", pos);
            std::string arrayString = xmlContent.str().substr(pos, endPos - pos);
            std::replace_if(arrayString.begin(), arrayString.end(), [](char c) { return !std::isdigit(c) && c != ','; }, ' ');
            std::istringstream ss(arrayString);
            int num;
            while (ss >> num) {
                result.push_back(num);
            }
        }
        return result;
    }*/

   static std::vector<int> stringToVector(const std::string& str) {
        std::vector<int> result;
        std::istringstream iss(str);
        std::string token;

        while (std::getline(iss, token, ',')) {
            result.push_back(std::stoi(token));
        }

        return result;
    }

   static void stringToArray(const std::string& str, int arr[], int size) {
       std::istringstream iss(str);
       std::string token;
       int index = 0;

       while (std::getline(iss, token, ',') && index < size) {
           arr[index++] = std::stoi(token);
       }
   }

};
