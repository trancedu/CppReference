#include <iostream>
#include <chrono>
#include <iomanip>
#include <sstream>
#include <type_traits>

template <typename Duration>
std::string convertToOracleInterval(Duration duration) {
    static_assert(std::is_convertible_v<Duration, std::chrono::seconds>,
                  "Duration must be convertible to std::chrono::seconds");

    using namespace std::chrono;

    // Convert duration to total seconds
    auto total_seconds = duration_cast<seconds>(duration).count();

    // Extract days, hours, minutes, and seconds
    auto days = total_seconds / 86400; // 1 day = 86400 seconds
    total_seconds %= 86400;

    auto hours = total_seconds / 3600; // 1 hour = 3600 seconds
    total_seconds %= 3600;

    auto minutes = total_seconds / 60; // 1 minute = 60 seconds
    total_seconds %= 60;

    auto seconds = total_seconds;

    // Construct the Oracle INTERVAL string
    std::ostringstream oss;
    oss << "INTERVAL '" << days << " "
        << std::setfill('0') << std::setw(2) << hours << ":"
        << std::setfill('0') << std::setw(2) << minutes << ":"
        << std::setfill('0') << std::setw(2) << seconds
        << "' DAY TO SECOND";

    return oss.str();
}

int main() {
    using namespace std::chrono;

    // Examples with different duration types
    auto duration1 = seconds(198615);     // 2 days, 10:30:15
    auto duration2 = minutes(1500);      // 25 hours
    auto duration3 = hours(72) + seconds(3605); // 3 days + 1:00:05

    std::cout << "Duration 1: " << convertToOracleInterval(duration1) << '\n';
    std::cout << "Duration 2: " << convertToOracleInterval(duration2) << '\n';
    std::cout << "Duration 3: " << convertToOracleInterval(duration3) << '\n';

    return 0;
}
