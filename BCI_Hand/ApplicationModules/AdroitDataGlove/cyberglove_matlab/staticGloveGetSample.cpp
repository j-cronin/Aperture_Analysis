#include <cstdlib>
#include <iostream>
#include "CyberGlove.h"
#include "mex.h"

static CyberGlove* persistentGlove = NULL;

void cleanup(void) {
    if(persistentGlove != NULL)
        delete persistentGlove;

    persistentGlove = NULL;
}                      

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{   
    /* Check for proper number of arguments. */
    if( nrhs != 2 ) {
        mexErrMsgTxt("Two inputs required - port then baudrate");
    } else if( nlhs > 1 ) {
        mexErrMsgTxt("Too many output arguments");
    }
    /* input must be a string */
    if ( mxIsChar(prhs[0]) != 1){
        mexErrMsgTxt("First input (portname) must be a string.");
    }

    if (persistentGlove == NULL) {
        /* Deal with port name input */
        char* portName;   
        portName = mxArrayToString(prhs[0]);   // copy string data from prhs[0] into C string     
        if(portName == NULL) 
        mexErrMsgTxt("Could not convert port name to string.");

        /* Deal with baud rate input */
        double* baudRate;
        baudRate = mxGetPr(prhs[1]);
            
        /* Create persistent glove */
        persistentGlove = new CyberGlove(portName, (int) *baudRate);

        mexAtExit(cleanup);
        mexPrintf("Created glove object.");
    } 
    
    /* Now finally get the sample */    
    std::vector<unsigned char> inputSample(persistentGlove->SampleSize());            
    persistentGlove->GetSample(&inputSample.front(), persistentGlove->SampleSize());        
    // Assign to output as column array
    plhs[0] = mxCreateNumericMatrix(persistentGlove->SampleSize(), 1, mxUINT8_CLASS, mxREAL);
    
    memcpy(mxGetPr(plhs[0]), &inputSample.front(), sizeof(unsigned char)*inputSample.size());    
    
  }





    