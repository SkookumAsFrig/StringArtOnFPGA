#ifndef CONFIG_H
#define CONFIG_H

#include <string>
#include "status.h"


class Config
{
public:
    bool invertInput;
    bool invertOutput;
    
    float threadThickness;
    float frameDiameter;

    unsigned int superSamplingWindowWidth;
    unsigned int numPins;
    unsigned int resolution;

    std::string importanceMapPath;
    std::string dataPath;
    std::string sourceImagePath;

    Config();
    ~Config(){};

    void printInfo();
    STATUS parseFile(std::string filePath);

private:
    void adaptThreadThickness();
};

#endif
