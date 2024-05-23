#include <iostream>
#include <vector>
#include "ZonotopeOperations.cpp"
#include "ReverseQueue.cu"
//#include "ReverseQueue.cu"
#pragma once

class TestCases
{
public:



    static void TestAnd() {
        LightLogicalZonotope lz{ 0, 1 };
        LightLogicalZonotope l1{ 1, 0 };
        LightLogicalZonotope l0{ 0, 0 };
        LightLogicalZonotope l2{ 1, 1 };

        LightLogicalZonotope andResult{ 0, 1 };



        And(lz, lz, andResult);
        std::cout << " lz & lz [" << andResult.Point << "," << andResult.Generator << "] and point is "
            << Evaluate(andResult)[0] << ", " << Evaluate(andResult)[1] << "\n";

        And(l1, l1, andResult);
        std::cout << "l1 & l1 [" << andResult.Point << "," << andResult.Generator << "] and point is "
            << Evaluate(andResult)[0] << ", " << Evaluate(andResult)[1] << "\n";

        And(l0, l0, andResult);
        std::cout << "l0 & l0 [" << andResult.Point << "," << andResult.Generator << "] and point is "
            << Evaluate(andResult)[0] << ", " << Evaluate(andResult)[1] << "\n";

        And(l2, l2, andResult);
        std::cout << " l2 & l2 [" << andResult.Point << "," << andResult.Generator << "] and point is "
            << Evaluate(andResult)[0] << ", " << Evaluate(andResult)[1] << "\n";

        And(lz, l1, andResult);
        std::cout << " lz & l1 [" << andResult.Point << "," << andResult.Generator << "] and point is "
            << Evaluate(andResult)[0] << ", " << Evaluate(andResult)[1] << "\n";

        And(lz, l0, andResult);
        std::cout << " lz & l0 [" << andResult.Point << "," << andResult.Generator << "] and point is "
            << Evaluate(andResult)[0] << ", " << Evaluate(andResult)[1] << "\n";

        And(lz, l2, andResult);
        std::cout << " lz & l2 [" << andResult.Point << "," << andResult.Generator << "] and point is "
            << Evaluate(andResult)[0] << ", " << Evaluate(andResult)[1] << "\n";

        And(l1, l0, andResult);
        std::cout << "l1 & l0 [" << andResult.Point << "," << andResult.Generator << "] and point is "
            << Evaluate(andResult)[0] << ", " << Evaluate(andResult)[1] << "\n";

        And(l1, l2, andResult);
        std::cout << "l1 & l2 [" << andResult.Point << "," << andResult.Generator << "] and point is "
            << Evaluate(andResult)[0] << ", " << Evaluate(andResult)[1] << "\n";

        And(l0, l2, andResult);
        std::cout << " l0 & l2 [" << andResult.Point << "," << andResult.Generator << "] and point is "
            << Evaluate(andResult)[0] << ", " << Evaluate(andResult)[1] << "\n";

        And(lz, l1, l0, andResult);
        std::cout << " lz & l1 & l0 [" << andResult.Point << "," << andResult.Generator << "] and point is "
            << Evaluate(andResult)[0] << ", " << Evaluate(andResult)[1] << "\n";

        And(l1, l0, l2, andResult);
        std::cout << " l1 & l0 & l2 [" << andResult.Point << "," << andResult.Generator << "] and point is "
            << Evaluate(andResult)[0] << ", " << Evaluate(andResult)[1] << "\n";

        And(lz, l1, l2, andResult);
        std::cout << " lz & l1 & l2 [" << andResult.Point << "," << andResult.Generator << "] and point is "
            << Evaluate(andResult)[0] << ", " << Evaluate(andResult)[1] << "\n";
    }
    static  void TestOr() {
        LightLogicalZonotope lz{ 0, 1 };
        LightLogicalZonotope l1{ 1, 0 };
        LightLogicalZonotope l0{ 0, 0 };
        LightLogicalZonotope l2{ 1, 1 };

        LightLogicalZonotope orResult{ 0, 1 };

        Or(lz, lz, orResult);
        std::cout << " lz | lz [" << orResult.Point << "," << orResult.Generator << "] and point is "
            << Evaluate(orResult)[0] << ", " << Evaluate(orResult)[1] << "\n";

        Or(l1, l1, orResult);
        std::cout << "l1 | l1 [" << orResult.Point << "," << orResult.Generator << "] and point is "
            << Evaluate(orResult)[0] << ", " << Evaluate(orResult)[1] << "\n";

        Or(l0, l0, orResult);
        std::cout << "l0 | l0 [" << orResult.Point << "," << orResult.Generator << "] and point is "
            << Evaluate(orResult)[0] << ", " << Evaluate(orResult)[1] << "\n";

        Or(l2, l2, orResult);
        std::cout << " l2 | l2 [" << orResult.Point << "," << orResult.Generator << "] and point is "
            << Evaluate(orResult)[0] << ", " << Evaluate(orResult)[1] << "\n";

        Or(lz, l1, orResult);
        std::cout << " lz | l1 [" << orResult.Point << "," << orResult.Generator << "] and point is "
            << Evaluate(orResult)[0] << ", " << Evaluate(orResult)[1] << "\n";

        Or(lz, l0, orResult);
        std::cout << " lz | l0 [" << orResult.Point << "," << orResult.Generator << "] and point is "
            << Evaluate(orResult)[0] << ", " << Evaluate(orResult)[1] << "\n";

        Or(lz, l2, orResult);
        std::cout << " lz | l2 [" << orResult.Point << "," << orResult.Generator << "] and point is "
            << Evaluate(orResult)[0] << ", " << Evaluate(orResult)[1] << "\n";

        Or(l1, l0, orResult);
        std::cout << "l1 | l0 [" << orResult.Point << "," << orResult.Generator << "] and point is "
            << Evaluate(orResult)[0] << ", " << Evaluate(orResult)[1] << "\n";

        Or(l1, l2, orResult);
        std::cout << "l1 | l2 [" << orResult.Point << "," << orResult.Generator << "] and point is "
            << Evaluate(orResult)[0] << ", " << Evaluate(orResult)[1] << "\n";

        Or(l0, l2, orResult);
        std::cout << " l0 | l2 [" << orResult.Point << "," << orResult.Generator << "] and point is "
            << Evaluate(orResult)[0] << ", " << Evaluate(orResult)[1] << "\n";

        Or(lz, l1, l0, orResult);
        std::cout << " lz | l1 | l0 [" << orResult.Point << "," << orResult.Generator << "] and point is "
            << Evaluate(orResult)[0] << ", " << Evaluate(orResult)[1] << "\n";

        Or(l1, l0, l2, orResult);
        std::cout << " l1 | l0 | l2 [" << orResult.Point << "," << orResult.Generator << "] and point is "
            << Evaluate(orResult)[0] << ", " << Evaluate(orResult)[1] << "\n";

        Or(lz, l1, l2, orResult);
        std::cout << " lz | l1 | l2 [" << orResult.Point << "," << orResult.Generator << "] and point is "
            << Evaluate(orResult)[0] << ", " << Evaluate(orResult)[1] << "\n";
    }

    static void TestNot() {
        LightLogicalZonotope lz{ 0, 1 };
        LightLogicalZonotope l1{ 1, 0 };
        LightLogicalZonotope l0{ 0, 0 };
        LightLogicalZonotope l2{ 1, 1 };

        LightLogicalZonotope notResult{ 0, 1 };

        Not(lz, notResult);
        std::cout << " NOT lz | lz [" << notResult.Point << "," << notResult.Generator << "] and point is "
            << Evaluate(notResult)[0] << ", " << Evaluate(notResult)[1] << "\n";

        Not(l1, notResult);
        std::cout << "NOT l1 [" << notResult.Point << "," << notResult.Generator << "] and point is "
            << Evaluate(notResult)[0] << ", " << Evaluate(notResult)[1] << "\n";

        Not(l0, notResult);
        std::cout << "NOT l0 [" << notResult.Point << "," << notResult.Generator << "] and point is "
            << Evaluate(notResult)[0] << ", " << Evaluate(notResult)[1] << "\n";

        Not(l2, notResult);
        std::cout << "NOT l2 [" << notResult.Point << "," << notResult.Generator << "] and point is "
            << Evaluate(notResult)[0] << ", " << Evaluate(notResult)[1] << "\n";
    }
    
   
   static void testReverseQueueSt() {
       ReverseQueue queue;
       initializeReverseQueue(&queue);

       std::cout << "Testing ReverseQueueSt:" << std::endl;

       try {
           std::cout << "Queue size = " << QueueSize(queue) << std::endl;

           std::cout << "Enqueueing 10..." << std::endl;
           Enqueue(queue, 10);
           std::cout << "Enqueueing 20..." << std::endl;
           Enqueue(queue, 20);
           std::cout << "Enqueueing 30..." << std::endl;
           Enqueue(queue, 30);

           std::cout << "Dequeuing..." << std::endl;
           std::cout << "Dequeued: " << Dequeue(queue) << std::endl;
           std::cout << "Dequeued: " << Dequeue(queue) << std::endl;
           std::cout << "Queue size = " << QueueSize(queue) << std::endl;
           std::cout << "Enqueueing 40..." << std::endl;
           Enqueue(queue, 40);
           std::cout << "Enqueueing 50..." << std::endl;
           Enqueue(queue, 50);

           std::cout << "Dequeuing..." << std::endl;
           std::cout << "Dequeued: " << Dequeue(queue) << std::endl;
           std::cout << "Dequeued: " << Dequeue(queue) << std::endl;
           std::cout << "Dequeued: " << Dequeue(queue) << std::endl;

           std::cout << "Queue size = " << QueueSize(queue) << std::endl;

       }
       catch (const std::exception& e) {
           std::cerr << "Exception: " << e.what() << std::endl;
       }

    }


};
