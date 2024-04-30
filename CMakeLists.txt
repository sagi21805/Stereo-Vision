cmake_minimum_required(VERSION 3.15) 
PROJECT ( Stereo )

set(CMAKE_C_COMPILER "/usr/bin/gcc-13")
set(CMAKE_CXX_COMPILER "/usr/bin/g++-13")

find_package(OpenCV REQUIRED )

set(CMAKE_CXX_FLAGS "-Wall -std=c++23 -O3 -save-temps")

include_directories(${OpenCV_INCLUDE_DIRS})
include_directories(${PROJECT_SOURCE_DIR}/source/c++/include)

file(GLOB source ${PROJECT_SOURCE_DIR}/source/c++/src/*.cpp)

add_executable(  ${PROJECT_NAME} ${source})
         
target_link_libraries( ${PROJECT_NAME} ${OpenCV_LIBS} ${nlohmann_json_LIBS})