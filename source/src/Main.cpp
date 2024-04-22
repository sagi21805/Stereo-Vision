#include "Stereo.hpp"


int main() {

    Camera cam(0, Size(2592, 1944), 2571.22);
    std::cout << cam.getFov() << "\n";

}