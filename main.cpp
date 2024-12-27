#include <iostream>

extern "C" {
    #include <libavformat/avformat.h>
}

// from tutorial: https://github.com/leandromoreira/ffmpeg-libav-tutorial
int main(const int argc, const char* argv[]) {
    if (argc < 2) {
        std::printf( "You should provide a file path as an argument.");
        return -1;
    }

    AVFormatContext* formatContext = avformat_alloc_context();
    if (formatContext == nullptr) {
        std::printf("Could not allocate memory for AVFormatContext\n");
        return -1;
    }

    const char* inputUrl = argv[1];
    if (avformat_open_input(&formatContext, inputUrl, nullptr, nullptr) != 0) {
        std::printf("Could not open file: %s\n", inputUrl);
        return -1;
    }

    std::printf("format %s, duration %lld s, bit_rate %lld\n", formatContext->iformat->name, formatContext->duration, formatContext->bit_rate);

    return 0;
}