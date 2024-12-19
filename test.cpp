#include <iostream>
#include <chrono>
#include <iomanip>
#include <sstream>
#include <type_traits>

template <typename Duration>
std::string convertToOracleDSInterval(Duration duration) {
    using namespace std::chrono;

    // Ensure the input duration can be represented as milliseconds
    auto total_milliseconds = duration_cast<milliseconds>(duration).count();

    // Extract days, hours, minutes, seconds, and milliseconds
    auto days = total_milliseconds / 86400000; // 1 day = 86400000 milliseconds
    total_milliseconds %= 86400000;

    auto hours = total_milliseconds / 3600000; // 1 hour = 3600000 milliseconds
    total_milliseconds %= 3600000;

    auto minutes = total_milliseconds / 60000; // 1 minute = 60000 milliseconds
    total_milliseconds %= 60000;

    auto seconds = total_milliseconds / 1000; // 1 second = 1000 milliseconds
    auto milliseconds = total_milliseconds % 1000;

    // Construct the string in TO_DSINTERVAL-compatible format
    std::ostringstream oss;
    oss << days << " "
        << std::setfill('0') << std::setw(2) << hours << ":"
        << std::setfill('0') << std::setw(2) << minutes << ":"
        << std::setfill('0') << std::setw(2) << seconds << "."
        << std::setfill('0') << std::setw(3) << milliseconds;

    return oss.str();
}

int main() {
    using namespace std::chrono;

    // Example duration (2 days, 10 hours, 30 minutes, 15 seconds, and 123 milliseconds)
    auto duration = hours(58) + minutes(30) + seconds(15) + milliseconds(123);

    std::string oracle_format = convertToOracleDSInterval(duration);
    std::cout << "Oracle DSInterval Format: " << oracle_format << '\n';

    auto duration2 = hours(58) + minutes(30) + seconds(15) + milliseconds(123);
    std::string oracle_format2 = convertToOracleDSInterval(duration2);
    std::cout << "Oracle DSInterval Format 2: " << oracle_format2 << '\n';

    auto duration3 = hours(0);
    std::string oracle_format3 = convertToOracleDSInterval(duration3);
    std::cout << "Oracle DSInterval Format 3: " << oracle_format3 << '\n';


    return 0;
}
