#include <iostream>
#include "LightLogicalZonotope.cpp"
#pragma once

//class ZonotopeOperations {
//public:
    static void Xor(const LightLogicalZonotope& zonotope1, const LightLogicalZonotope& zonotope2, LightLogicalZonotope& zonotopeOut) {
        if (zonotope2.Generator != 0)
            zonotopeOut.Generator = 1;
        else if (zonotope1.Generator != 0)
            zonotopeOut.Generator = 1;
        else {
            zonotopeOut.Generator = 0;
            zonotopeOut.Point = zonotope1.Point ^ zonotope2.Point;
        }
    }

    static void Xor(const LightLogicalZonotope& zonotope1, const LightLogicalZonotope& zonotope2, const LightLogicalZonotope& zonotope3, LightLogicalZonotope& zonotopeOut) {
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

    static void Xor(const LightLogicalZonotope& zonotope1, const LightLogicalZonotope& zonotope2, const LightLogicalZonotope& zonotope3, const LightLogicalZonotope& zonotope4, LightLogicalZonotope& zonotopeOut) {
        if (zonotope1.Generator != 0)
            zonotopeOut.Generator = 1;
        else if (zonotope2.Generator != 0)
            zonotopeOut.Generator = 1;
        else if (zonotope3.Generator != 0)
            zonotopeOut.Generator = 1;
        else if (zonotope4.Generator != 0)
            zonotopeOut.Generator = 1;
        else {
            zonotopeOut.Generator = 0;
            zonotopeOut.Point = zonotope1.Point ^ zonotope2.Point ^ zonotope3.Point ^ zonotope4.Point;
        }
    }

    static void And(const LightLogicalZonotope& zonotope1, const LightLogicalZonotope& zonotope2, LightLogicalZonotope& zonotopeOut) {
        zonotopeOut.Generator = 0;
        zonotopeOut.Point = 0;

        int certainPointsCount = 0;

        if (zonotope2.Generator == 0) {
            if (zonotope2.Point == 0)
                return;
            certainPointsCount++;
        }

        if (zonotope1.Generator == 0) {
            if (zonotope1.Point == 0)
                return;
            certainPointsCount++;
        }

        if (certainPointsCount == 2)
            zonotopeOut.Point = 1;
        else
            zonotopeOut.Generator = 1;
    }

    static void And(const LightLogicalZonotope& zonotope1, const LightLogicalZonotope& zonotope2, const LightLogicalZonotope& zonotope3, LightLogicalZonotope& zonotopeOut) {
        zonotopeOut.Generator = 0;
        zonotopeOut.Point = 0;

        int certainPointsCount = 0;

        if (zonotope3.Generator == 0) {
            if (zonotope3.Point == 0)
                return;
            certainPointsCount++;
        }

        if (zonotope2.Generator == 0) {
            if (zonotope2.Point == 0)
                return;
            certainPointsCount++;
        }

        if (zonotope1.Generator == 0) {
            if (zonotope1.Point == 0)
                return;
            certainPointsCount++;
        }

        if (certainPointsCount == 3)
            zonotopeOut.Point = 1;
        else
            zonotopeOut.Generator = 1;
    }

    static void Or(const LightLogicalZonotope& zonotope1, const LightLogicalZonotope& zonotope2, LightLogicalZonotope& zonotopeOut) {
        zonotopeOut.Generator = 0;
        zonotopeOut.Point = 1;

        int certainPointsCount = 0;

        if (zonotope2.Generator == 0) {
            if (zonotope2.Point == 1)
                return;
            certainPointsCount++;
        }

        if (zonotope1.Generator == 0) {
            if (zonotope1.Point == 1)
                return;
            certainPointsCount++;
        }

        if (certainPointsCount == 2)
            zonotopeOut.Point = 0;
        else {
            zonotopeOut.Point = 0;
            zonotopeOut.Generator = 1;
        }
    }

    static void Or(const LightLogicalZonotope& zonotope1, const LightLogicalZonotope& zonotope2, const LightLogicalZonotope& zonotope3, LightLogicalZonotope& zonotopeOut) {
        zonotopeOut.Generator = 0;
        zonotopeOut.Point = 1;

        int certainPointsCount = 0;

        if (zonotope3.Generator == 0) {
            if (zonotope3.Point == 1)
                return;
            certainPointsCount++;
        }

        if (zonotope2.Generator == 0) {
            if (zonotope2.Point == 1)
                return;
            certainPointsCount++;
        }

        if (zonotope1.Generator == 0) {
            if (zonotope1.Point == 1)
                return;
            certainPointsCount++;
        }

        if (certainPointsCount == 3)
            zonotopeOut.Point = 0;
        else {
            zonotopeOut.Point = 0;
            zonotopeOut.Generator = 1;
        }
    }

    static void Not(const LightLogicalZonotope& zonotope, LightLogicalZonotope& zonotopeOut) {
        zonotopeOut.Point = 1 - zonotope.Point;

        if (zonotope.Generator == 0)
            zonotopeOut.Generator = 0;
        else {
            zonotopeOut.Generator = 1;
            zonotopeOut.Point = 0;
        }
    }
//};