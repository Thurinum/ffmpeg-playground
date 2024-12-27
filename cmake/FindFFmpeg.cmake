find_package(PkgConfig QUIET)

set(FFMPEG_LIB_DIR $ENV{FFMPEG_LIB_DIR})
set(FFMPEG_INCLUDE_DIR $ENV{FFMPEG_INCLUDE_DIR})

list(LENGTH FFmpeg_FIND_COMPONENTS NUM_COMPONENTS)
if (LIST_LENGTH EQUAL 0)
    message(NOTICE "No FFmpeg components specified. Defaulting to everything.")
    set(FFmpeg_FIND_COMPONENTS avcodec avdevice avfilter avformat avresample avutil postproc swresample swscale)
endif()

if (FFMPEG_LIB_DIR AND FFMPEG_INCLUDE_DIR)
    message(STATUS "Found env variables FFMPEG_LIB_DIR (${FFMPEG_LIB_DIR}) and FFMPEG_INCLUDE_DIR (${FFMPEG_INCLUDE_DIR}).")

    foreach (COMPONENT IN LISTS FFmpeg_FIND_COMPONENTS)
        find_library(${COMPONENT}_LIB ${COMPONENT} HINTS ${FFMPEG_LIB_DIR})
        if (NOT ${COMPONENT}_LIB)
            message(FATAL_ERROR "Failed to locate FFmpeg component '${COMPONENT}'. "
                                "Ensure FFMPEG_LIB_DIR is set to a directory containing the FFmpeg shared libraries.")
        endif()

        message(STATUS "Found FFmpeg component '${COMPONENT}'.")

        add_library(FFmpeg::${COMPONENT} INTERFACE IMPORTED)
        target_include_directories(FFmpeg::${COMPONENT} INTERFACE ${FFMPEG_INCLUDE_DIR})
        target_link_directories(FFmpeg::${COMPONENT} INTERFACE ${FFMPEG_LIB_DIR})
        target_link_libraries(FFmpeg::${COMPONENT} INTERFACE ${COMPONENT})
    endforeach()
else()
    if (NOT PkgConfig_FOUND)
        message(FATAL_ERROR [=[
    Could not locate pkg-config. Either:
    - Install pkg-config, if available on your platform, alongside the FFmpeg development libraries.
    - Set the FFMPEG_LIB_DIR (shared libs directory) and FFMPEG_INCLUDE_DIR (.h directory) environment variables.
        ]=])
    endif()

    message(STATUS "Found pkg-config. Using it to locate FFmpeg.")

    pkg_check_modules(FFMPEG REQUIRED IMPORTED_TARGET ${FFMPEG_LIBS})
    add_library(FFmpeg::FFmpeg ALIAS PkgConfig::FFMPEG)
    message(STATUS "Found FFmpeg libraries: ${FFMPEG_LIBS}.")
endif()