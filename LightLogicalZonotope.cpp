#include <iostream>
#include <vector>
#pragma once

//class LightLogicalZonotope {
//public:
//    int Point;
//    int Generator;
//
//    // Default constructor
//    LightLogicalZonotope() : Point(0), Generator(0) {}
//
//    // Parameterized constructor
//    LightLogicalZonotope(int point, int generator) : Point(point), Generator(generator) {}
//
//    // Destructor (if needed)
//    ~LightLogicalZonotope() {}
//
//    // Copy constructor
//    LightLogicalZonotope(const LightLogicalZonotope& other) : Point(other.Point), Generator(other.Generator) {}
//
//    std::vector<int> Evaluate() const {
//        // Check if the generator array is empty
//        if (Generator == 0) {
//            // Return an array of integers with one element, which is the point
//            return std::vector<int>{Point};
//        }
//
//        std::vector<int> points(2, 0);
//        // Simplified version when we have only one generator
//        points[0] = Point;
//        points[1] = Point ^ Generator;
//        return points;
//    }
//
//};

struct LightLogicalZonotope
{
    int Point;
    int Generator;

}; 

static std::vector<int> Evaluate(LightLogicalZonotope lz) {
        // Check if the generator array is empty
        if (lz.Generator == 0) {
            // Return an array of integers with one element, which is the point
            return std::vector<int>{lz.Point, 100000000};
        }

        std::vector<int> points(2, 0);
        // Simplified version when we have only one generator
        points[0] = lz.Point;
        points[1] = lz.Point ^ lz.Generator;
        return points;
    }