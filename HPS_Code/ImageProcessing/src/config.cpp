#include <iostream>
#include <fstream>
#include <iomanip>
#include <math.h>
#include "../include/config.h"

Config::Config()
{
    invertInput = true;
    invertOutput = true;
    threadThickness = 0.15;
    frameDiameter = 614.4;
    superSamplingWindowWidth = 8;
    numPins = 256;
    importanceMapPath = "";
    sourceImagePath = "";
    dataPath = "../data";
    adaptThreadThickness();
}

void Config::printInfo()
{
    std::cout << "===========================================================" << std::endl;
    std::cout << "===========================================================" << std::endl;
    std::cout << std::setw(30)  << "InvertInput: " << std::setw(20) << (invertInput == 1 ? "True" : "False") << std::endl;
    std::cout << std::setw(30)  << "InvertOutput: "  << std::setw(20) << (invertOutput == 1 ? "True" : "False") << std::endl;
    std::cout << std::setw(30)  << "ThreadThickness: " << std::setw(20) << threadThickness << std::endl;
    std::cout << std::setw(30)  << "FrameDiameter: " << std::setw(20) << frameDiameter << std::endl;
    std::cout << std::setw(30)  << "SuperSamplingWindowWidth: " << std::setw(20) << superSamplingWindowWidth << std::endl;
    std::cout << std::setw(30)  << "NumPins: " << std::setw(20) << numPins << std::endl;
    std::cout << std::setw(30)  << "Resolution: " << std::setw(20) << resolution << std::endl;
    std::cout << std::setw(30)  << "ImportanceMapPath: " << std::setw(20) << (importanceMapPath == "" ? "NULL" : importanceMapPath)  << std::endl;
    std::cout << std::setw(30)  << "DataPath: " << std::setw(20) << (dataPath == "" ? "NULL" : dataPath) << std::endl;
    std::cout << std::setw(30)  << "SourceImagePath: " << std::setw(20) << (sourceImagePath == "" ? "NULL" : sourceImagePath) << std::endl;
    std::cout << "===========================================================" << std::endl;
    std::cout << "===========================================================" << std::endl;
}

STATUS Config::parseFile(std::string filePath)
{
    if(filePath == "")
        return STATUS::PARSE_DEFAULT;
    std::fstream fs;
    fs.open(filePath, std::fstream::in);
    if(fs.is_open()){
        std::string line;
        while( getline(fs, line) ){
            std::string attribution = line.substr(0, line.find(":"));
            std::string value =  line.substr(line.find(":") + 1);
            if(attribution == "InvertInput"){
                invertInput = value == "1";
            }else if(attribution == "InvertOutput"){
                invertOutput = value == "1";
            }else if(attribution == "ThreadThickness"){
                threadThickness = std::stof(value);
            }else if(attribution == "FrameDiameter"){
                frameDiameter = std::stof(value);
            }else if(attribution == "SuperSamplingWindowWidth"){
                superSamplingWindowWidth = (unsigned int)std::stoi(value);
            }else if(attribution == "NumPins"){
                numPins = (unsigned int)std::stoi(value);
            }else if(attribution == "ImportanceMapPath"){
                importanceMapPath = value;
            }else if(attribution == "DataPath"){
                dataPath = value;
            }else if(attribution == "SourceImagePath"){
                sourceImagePath = value;
            }else{
                return STATUS::PARSE_FORMAT_ERROR;
            }
        }
    }
    else{
        return STATUS::PARSE_FILE_OPEN_ERROR;
    }
    adaptThreadThickness();
    fs.close();
    return STATUS::PARSE_SUCCESS;
}

void Config::adaptThreadThickness()
{
    double temp =  frameDiameter / threadThickness;
    resolution = (unsigned int)pow(2,ceil(log2(temp)));
    threadThickness = frameDiameter / resolution;
}