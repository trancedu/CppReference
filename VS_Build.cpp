#include <windows.h>
#include <iostream>
#include <thread>
#include <random>
#include <chrono>
#include <atomic>

std::atomic<bool> active(true);
std::atomic<bool> shouldTerminate(false);

void simulateMouseScroll(int scrollAmount) {
    INPUT input = { 0 };
    input.type = INPUT_MOUSE;
    input.mi.mouseData = scrollAmount;
    input.mi.dwFlags = MOUSEEVENTF_WHEEL;
    SendInput(1, &input, sizeof(INPUT));
}

void simulateMouseMove(int dx, int dy) {
    INPUT input = { 0 };
    input.type = INPUT_MOUSE;
    input.mi.dx = dx;
    input.mi.dy = dy;
    input.mi.dwFlags = MOUSEEVENTF_MOVE;
    SendInput(1, &input, sizeof(INPUT));
}

void randomMouseMovement() {
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(-1, 1);

    while (true) {
        if (active) {
            int dx = dis(gen);
            int dy = dis(gen);
            simulateMouseMove(dx, dy);
        }
        std::this_thread::sleep_for(std::chrono::seconds(590));
    }
}

void periodicMouseScroll() {
    while (true) {
        if (active) {
            simulateMouseScroll(-WHEEL_DELTA);
        }
        std::this_thread::sleep_for(std::chrono::seconds(600));
    }
}

void checkActivePeriod() {
    while (true) {
        auto now = std::chrono::system_clock::now();
        std::time_t currentTime = std::chrono::system_clock::to_time_t(now);
        std::tm localTime;
        localtime_s(&localTime, &currentTime);

        int hour = localTime.tm_hour;
        active = !(hour >= 12 && hour < 13);
        std::cout << "Active: " << active << " at " << hour << " o'clock" << std::endl;

        if (hour >= 18) {
            shouldTerminate = true;
            break;
        }

        std::this_thread::sleep_for(std::chrono::minutes(10));
    }
}

int main() {
    std::thread mouseThread(randomMouseMovement);
    mouseThread.detach();

    std::thread scrollThread(periodicMouseScroll);
    scrollThread.detach();

    std::thread activeCheckThread(checkActivePeriod);
    activeCheckThread.detach();

    while (!shouldTerminate) {
        std::this_thread::sleep_for(std::chrono::seconds(600));
    }

    std::cout << "Terminates" << std::endl;
    return 0;
}
