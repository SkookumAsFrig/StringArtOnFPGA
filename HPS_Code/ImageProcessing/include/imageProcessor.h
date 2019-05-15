#ifndef IMAGE_PROCESSOR_H
#define IMAGE_PROCESSOR_H

#include "config.h"
#include "status.h"
#include <string>

class ImageProcessor{

private:
    std::string m_imageFile;
    std::string m_outPath;
    unsigned int m_highRes;
    unsigned int m_lowRes;
    bool m_debug;

    void printInfo();

public:
    ImageProcessor() : m_imageFile(""), m_outPath(""), m_highRes(0), m_lowRes(0){};
    ~ImageProcessor(){};
    ImageProcessor(Config const *config, bool debug = false);
    STATUS work();

};

#endif