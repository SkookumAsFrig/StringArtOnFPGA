#include <iostream>
#include <stdio.h>
#include <string.h>
#include "../include/config.h"
#include "../include/status.h"
#include "../include/imageProcessor.h"
#include "../include/matrixGenerator.h"
#include <sys/stat.h>


int main(int argc, char *argv[])
{
  Config* config = new Config();
  std::string filePath = "";
  if (argc > 1){
      filePath = argv[1];
  }
  STATUS parse_status = config->parseFile(filePath);
  if(parse_status == STATUS::PARSE_DEFAULT){
    std::cout << "[INFO]Use default configuration" << std::endl;
  }else if(parse_status == STATUS::PARSE_FILE_OPEN_ERROR){
    std::cout << "[ERROR]Configuration file open error" << std::endl;
    return -1;
  }else if(parse_status == STATUS::PARSE_FORMAT_ERROR){
    std::cout << "[ERROR]Configuration file format error" << std::endl;
    return -1;
  }else{
    std::cout << "[INFO]Configuration parse succeed" << std::endl;
  }
  config->printInfo();

  struct stat sb;

  if(stat(config->dataPath.c_str(), &sb) != 0 || !S_ISDIR(sb.st_mode)){
    char inst[256];
    strcpy(inst, "mkdir ");
    strcat(inst, config->dataPath.c_str());
    system(inst);
    std::cout << "[INFO]Data directory generation success" << std::endl;
  }else{
    std::cout << "[INFO]Data directory exists. System would use existing directory" << std::endl;
  }

  ImageProcessor* imageProcessor = new ImageProcessor(config, false);
  STATUS image_status = imageProcessor -> work();
  if(image_status != STATUS::IMAGE_PROCESS_SUCCESS){
    std::cout << "[ERROR]System would terminate due to image processor error" << std::endl;
  }
  if(imageProcessor != NULL){
    delete imageProcessor;
  }
  

  MatrixGenerator* matGen = new MatrixGenerator(config, true);
  matGen -> work();

  return 0; 
}
