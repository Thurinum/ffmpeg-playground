cmake_minimum_required(VERSION 3.22.1)
project(ffmpeg_tests)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Werror -pedantic")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")
set(APP_OUTPUT_DIR ${CMAKE_SOURCE_DIR}/bin)

find_package(FFmpeg REQUIRED COMPONENTS avcodec avformat avutil)

add_executable(ffmpeg_tests main.cpp)
target_link_libraries(ffmpeg_tests FFmpeg::avcodec FFmpeg::avformat FFmpeg::avutil)
set_target_properties(ffmpeg_tests PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${APP_OUTPUT_DIR}
)