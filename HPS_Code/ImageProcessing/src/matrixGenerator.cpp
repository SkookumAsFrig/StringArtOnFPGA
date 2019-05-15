#include "../include/matrixGenerator.h"
#include <fstream>
#include <iostream>
#include <string>
#include <math.h>

MatrixGenerator::~MatrixGenerator(){
    if(m_pinMat != NULL){
        delete m_pinMat;
    }
}

STATUS MatrixGenerator::m_pinMatrixGeneration(){
    if(m_numPins <= 1){
        std::cout << "[ERROR]Invalid pin number, which should be greater than 2." << std::endl;
        return STATUS::INVALID_PIN_NUMBER;
    }else if(m_numPins < 128){
        std::cout << "[WARNING]Pin Number is less than 128, which may lead to worse result." << std::endl;
    }else if(m_numPins > 1024){
        std::cout << "[WARNING]Pin Number is too large, which may consume long time." << std::endl;
    }

    double angle = 2 * M_PI / m_numPins;
    m_pinMat =  new Eigen::MatrixXd(m_numPins,2);
    for( int i = 0; i < m_numPins; i++){
        (*m_pinMat)(i,0) = sin(i*angle);
        (*m_pinMat)(i,1) = cos(i*angle);
    }
    if(m_debug){
        std::cout << "[INFO]Pin angle matrix would be logged into file." << std::endl;
        std::ofstream fout;
        fout.open("pinLog.txt");
        if(!fout.is_open()){
            std::cout << "[WARNING]Log file open error. Do you want to continue?(yes/no)" << std::endl;
            std::string reply;
            std::cin >> reply;
            while(reply != "yes" && reply != "no"){
                std::cout << "[ERROR]Please type yes for recept and no for reject." << std::endl;
            }
            if(reply == "no"){
                std::cout << "[ERROR]System would terminate due to log file open error" << std::endl;
                return STATUS::PIN_LOG_FILE_OPEN_ERROR;
            }
        }else{
            fout << *m_pinMat << std::endl;
            fout.close();
        }
    }
    return STATUS::PIN_MATRIX_GENERATION_SUCCESS;
}

STATUS MatrixGenerator::work(){
    STATUS pinMat_status = m_pinMatrixGeneration();
    if(pinMat_status != STATUS::PIN_MATRIX_GENERATION_SUCCESS){
        return pinMat_status;
    }

    //[TODO]Low Resolution is valid for VERSION 1
    unsigned int pixel_radius = m_lowRes/2;

    (*m_pinMat) *= pixel_radius;
    Eigen::MatrixXd* temp_add = new Eigen::MatrixXd(m_numPins,2);
    (*temp_add).setOnes();
    (*temp_add) *= (double)pixel_radius;
    (*m_pinMat) += (*temp_add);
    delete temp_add;
    (*m_pinMat) = (*m_pinMat).array().floor().matrix();

    return STATUS::ALL_MATRIX_GENERATION_SUCCESS;
}