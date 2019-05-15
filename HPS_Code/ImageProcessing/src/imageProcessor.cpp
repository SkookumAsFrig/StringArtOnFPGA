#include "../include/imageProcessor.h"
#include <iostream>
#include <iomanip>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <sys/stat.h>

ImageProcessor::ImageProcessor(Config const * config, bool debug)
{
    m_imageFile = config -> sourceImagePath;
    unsigned int first_pos = m_imageFile.find_last_of("/");
    unsigned int end_pos = m_imageFile.find_last_of(".");
    m_outPath   = config -> dataPath + m_imageFile.substr(first_pos, end_pos-first_pos);
    m_highRes   = config -> resolution;
    m_lowRes    = config -> resolution / config -> superSamplingWindowWidth;
    m_debug     = debug;
}

void ImageProcessor::printInfo()
{
    std::cout << "===========================================================" << std::endl;
    std::cout << "===========================================================" << std::endl;
    std::cout << std::setw(20) << "ImagePath:" << std::setw(20) << m_imageFile << std::endl;
    std::cout << std::setw(20) << "OutputPath" << std::setw(20) << m_outPath   << std::endl;
    std::cout << std::setw(20) << "HighResolution" << std::setw(20) << m_highRes << std::endl;
    std::cout << std::setw(20) << "LowResolution" << std::setw(20) << m_lowRes << std::endl;
    std::cout << "===========================================================" << std::endl;
    std::cout << "===========================================================" << std::endl;
}

STATUS ImageProcessor::work()
{
    if(m_debug){
        std::cout << "[INFO]Debug mode is ON. More info would be printed." << std::endl;
        printInfo();
    }
    cv::Mat oriImage = cv::imread( m_imageFile , cv::IMREAD_GRAYSCALE );
    if( ! oriImage.data ){
        std::cout << "[ERROR]Image file cannot open. Processor would be terminated!" << std::endl;
        return STATUS::IMAGE_FILE_OPEN_ERROR;
    }
    CV_Assert( oriImage.depth() == CV_8U );

    cv::Mat resizeImage = cv::Mat(m_lowRes, m_lowRes, oriImage.type());
    cv::resize(oriImage, resizeImage, resizeImage.size(), 0, 0);
    cv::Mat mask = cv::Mat(m_lowRes, m_lowRes, CV_8U);
    cv::Mat target = cv::Mat(m_lowRes, m_lowRes, resizeImage.type());
    unsigned int center = m_lowRes/2;
    for(int i = 0; i < mask.rows; i++){
        for(int j = 0; j < mask.cols; j++){
            if ( (i-center) * (i-center) + (j-center) * (j-center) > center * center ){
                mask.at<unsigned char>(i,j) = 0;
                target.at<unsigned char>(i,j) = 255;
            }else{
                mask.at<unsigned char>(i,j) = 1;
            }
        }
    }
    resizeImage.copyTo(target, mask);
    if(m_debug){
        cv::imshow( "Display", target);
        std::cout << "[INFO]Press any key to continue." << std::endl;
        cv::waitKey(0);
    }

    struct stat sb;
    if(stat(m_outPath.c_str(), &sb) != 0){
        char inst[256];
        strcpy(inst, "mkdir ");
        strcat(inst, m_outPath.c_str());
        system(inst);
        std::cout << "[INFO]Image output directory generation success" << std::endl;;
    }else{
        std::cout << "[INFO]Image output directory exists. System would use existing directory" << std::endl;
    }

    std::string targetFile = m_outPath + "/target.png";
    cv::imwrite(targetFile, target);
    std::cout << "[INFO]Target image output success" << std::endl;
    
    return STATUS::IMAGE_PROCESS_SUCCESS;
}