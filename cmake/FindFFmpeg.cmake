find_package(PkgConfig QUIET)

# config options when not using pkg-config
option(FFMPEG_INCLUDE_DIR "Path to the directory containing the FFmpeg header files.")
if (WIN32)
    option(FFMPEG_LIB_DIR "Should point to the .lib import libraries.")
    option(FFMPEG_BIN_DIR "Should point to the FFmpeg .dll files.")
else()
    option(FFMPEG_LIB_DIR "Should point to the .so shared libraries.")
endif()

# detect empty components list
list(LENGTH FFmpeg_FIND_COMPONENTS NUM_COMPONENTS)
if (NUM_COMPONENTS EQUAL 0)
    message(STATUS "No FFmpeg components specified. Defaulting to link against everything.")
    set(FFmpeg_FIND_COMPONENTS avcodec avdevice avfilter avformat avresample avutil postproc swresample swscale)
endif()

# if paths are explicitly set, use them; otherwise, try to use pkg-config
if (FFMPEG_LIB_DIR AND FFMPEG_INCLUDE_DIR)
    message(STATUS "Found options FFMPEG_LIB_DIR (${FFMPEG_LIB_DIR}) and FFMPEG_INCLUDE_DIR (${FFMPEG_INCLUDE_DIR}).")

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

    if (FFMPEG_BIN_DIR)
        message(STATUS "Found option FFMPEG_BIN_DIR (${FFMPEG_BIN_DIR}). Moving DLLs to ${APP_OUTPUT_DIR}.")
        file(GLOB_RECURSE DLLS "${FFMPEG_BIN_DIR}/*.dll")
        foreach (DLL IN LISTS DLLS)
            file(COPY "${DLL}" DESTINATION "${APP_OUTPUT_DIR}")
        endforeach()
    else()
        message(WARNING "FFMPEG_BIN_DIR not set. Ensure FFmpeg .dll files are in your PATH or your binary's directory.")
    endif()
else()
    if (NOT PkgConfig_FOUND)
        message(FATAL_ERROR [=[
    Could not locate pkg-config. Either:
    - Install pkg-config, if available on your platform, alongside the FFmpeg development libraries.
    - Set the FFMPEG_LIB_DIR (shared libs directory) and FFMPEG_INCLUDE_DIR (.h directory) CMake options.
        ]=])
    endif()

    message(STATUS "Found pkg-config. Using it to locate FFmpeg.")

    foreach (COMPONENT IN LISTS FFmpeg_FIND_COMPONENTS)
        pkg_check_modules(${COMPONENT} REQUIRED IMPORTED_TARGET lib${COMPONENT})
        add_library(FFmpeg::${COMPONENT} INTERFACE IMPORTED)
        target_include_directories(FFmpeg::${COMPONENT} INTERFACE ${FFMPEG_INCLUDE_DIR})
        target_link_directories(FFmpeg::${COMPONENT} INTERFACE ${FFMPEG_LIB_DIR})
        target_link_libraries(FFmpeg::${COMPONENT} INTERFACE ${COMPONENT})
    endforeach()
endif()