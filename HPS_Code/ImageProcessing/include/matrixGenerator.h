#ifndef MATRIX_GENERATOR_H
#define MATRIX_GENERATOR_H

#include <Eigen/Dense>
#include "config.h"
#include "status.h"

class MatrixGenerator{

private:
    unsigned int m_numPins;
    unsigned int m_highRes;
    unsigned int m_lowRes;
    bool m_debug;
    Eigen::MatrixXd* m_pinMat;

    STATUS m_pinMatrixGeneration();    

public:
    MatrixGenerator(): m_numPins(256), m_highRes(0), m_lowRes(0), m_debug(false), m_pinMat(NULL){};
    MatrixGenerator(Config const *config, bool debug = false): m_numPins(config -> numPins), m_highRes(config -> resolution),
                            m_lowRes(config -> resolution/config -> superSamplingWindowWidth),m_debug(debug), m_pinMat(NULL){};
    ~MatrixGenerator();

    STATUS work();

};

#endif