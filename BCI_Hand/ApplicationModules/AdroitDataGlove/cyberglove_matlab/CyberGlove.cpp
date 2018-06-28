
#include <stdexcept>
#include "CyberGlove.h"

const char* CyberGlove::Control::Reset           = "\x12";
const char  CyberGlove::Control::Cancel          = '\x3';
const char  CyberGlove::Control::StreamSamples   = 'S';
const char  CyberGlove::Control::GetSingleSample = 'G';

const char CyberGlove::Parameter::TimeStamp           = 'D';
const char CyberGlove::Parameter::Filter              = 'F';
const char CyberGlove::Parameter::SwitchControlsLight = 'J';
const char CyberGlove::Parameter::Light               = 'L';
const char CyberGlove::Parameter::SendQuantized       = 'Q';
const char CyberGlove::Parameter::GloveStatus         = 'U';
const char CyberGlove::Parameter::Switch              = 'W';
const char CyberGlove::Parameter::ExternalSynch       = 'Y';


const char* CyberGlove::Query::BaudRate            = "?B";
const char* CyberGlove::Query::Calibration         = "?C";
const char* CyberGlove::Query::SoftwareSensorMask  = "?M";
const char* CyberGlove::Query::SampleSize          = "?N";
const char* CyberGlove::Query::ParameterFlags      = "?P";
const char* CyberGlove::Query::SamplePeriod        = "?T";
const char* CyberGlove::Query::GloveValid          = "?G";
const char* CyberGlove::Query::Information         = "?I";
const char* CyberGlove::Query::HardwareSensorMask  = "?K";
const char* CyberGlove::Query::RightHanded         = "?R";
const char* CyberGlove::Query::SensorCount         = "?S";
const char* CyberGlove::Query::Version             = "?V";
const char* CyberGlove::Query::TimeStampEnabled    = "?D";
const char* CyberGlove::Query::FilterStatus        = "?F";
const char* CyberGlove::Query::SwitchControlsLight = "?J";
const char* CyberGlove::Query::Light               = "?L";

    //if(value == 'e')
    //{// Result: Error
    //    value = ReadByte();
    //    SynchInput(value);
    //    switch(value)
    //    {
    //    case '?': throw std::runtime_error("Unknown command");
    //    case 'n': throw std::runtime_error("Too many numbers entered");
    //    case 'y': throw std::runtime_error("Synch input-rate too fast");
    //    case 'g': throw std::runtime_error("Glove not plugged in");
    //    case 's': throw std::runtime_error("Sampling rate too fast");
    //    default:  throw std::runtime_error("Unknown error");
    //    }
    //}

#undef min


CyberGlove::CyberGlove(const std::string &portName, int baudRate)
{
    port = CreateFile(portName.c_str(),GENERIC_READ|GENERIC_WRITE,0,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
    if(port == INVALID_HANDLE_VALUE)
        throw std::runtime_error("Cannot open port");
    
    DCB params;
    GetCommState(port, &params);
    params.DCBlength = sizeof(DCB);
    params.BaudRate  = baudRate;
    params.ByteSize  = 8;
    params.StopBits  = ONESTOPBIT;
    params.Parity    = NOPARITY;

    if(!SetCommState(port, &params))
    {
        CloseHandle(port);
        throw std::runtime_error("Cannot set serial-port state");
    }

    COMMTIMEOUTS timeouts; // In milliseconds
    timeouts.ReadIntervalTimeout         = 1000;
    timeouts.ReadTotalTimeoutConstant    = 1000;
    timeouts.ReadTotalTimeoutMultiplier  = 1000;
    timeouts.WriteTotalTimeoutConstant   = 1000;
    timeouts.WriteTotalTimeoutMultiplier = 1000;
    
    if(!SetCommTimeouts(port, &timeouts))
    {
        CloseHandle(port);
        throw std::runtime_error("Cannot set serial-port timeouts");
    }

    Reset();
}

CyberGlove::~CyberGlove()
{
    if(port != INVALID_HANDLE_VALUE)
        CloseHandle(port);
}

void CyberGlove::Reset(bool hardwareReset)
{
    if(hardwareReset)
        SendCommand(Control::Reset,NULL,0);
    else
        ClearInput();

    isStreaming = false;
    sensorCount = (size_t)QueryByte(Query::SensorCount);
    sampleSize = (size_t)QueryByte(Query::SampleSize);
    timeStampsEnabled = (bool)QueryByte(Query::TimeStampEnabled);

    // Set the sampling rate
    WriteByte('T');
    unsigned short w1 = 1440; // 80 Hz; 1440 = 115200 / 80
    unsigned short w2 = 1;
    WriteByte((uchar)(w1>>8));
    WriteByte((uchar)w1);
    WriteByte((uchar)(w2>>8));
    WriteByte((uchar)w2);
    SynchInput();
}

unsigned char CyberGlove::ReadByte()
{
    DWORD bytesRead;
    char result;
    if(!ReadFile(port, &result, 1, &bytesRead, NULL) || bytesRead != 1)
        throw std::runtime_error("Could not read data from serial-port");
    else
        return result;
}

void CyberGlove::WriteByte(unsigned char value)
{
    DWORD bytesWritten;
    if(!WriteFile(port, &value, 1, &bytesWritten, NULL))
        throw std::runtime_error("Could not write data to serial-port");
}

void CyberGlove::SynchInput(char value)
{
    while(value)
        value = ReadByte();
}

void CyberGlove::ClearInput(void)
{
    static char nul[32];
    DWORD bytesRead;

    do
    {
        if(!ReadFile(port, nul, sizeof(nul), &bytesRead, NULL))
            throw std::runtime_error("Could not read data from serial-port");
    } while(bytesRead == 32);
}

void CyberGlove::WriteCommand(const char* command)
{
    if(!command)
        throw std::runtime_error("Null command");
    size_t length = strlen(command);    

    DWORD bytes;
    if(!WriteFile(port, command, length, &bytes, NULL) || bytes != length)
        throw std::runtime_error("Could not write data to serial-port");

    char value = ReadByte();

    if(value != command[0])
    {
        SynchInput(value);
        throw std::runtime_error("Response is not synchronized");
    }

    // Read past command-echo
    for(size_t idx = 1; idx < length; ++idx)
    {
        value = ReadByte();
        if(value != command[idx])
        {
            SynchInput(value);
            throw std::runtime_error("Response is not synchronized");
        }
    }
}

void CyberGlove::SetParameter(const char parameter, bool enabled)
{
    WriteByte(parameter);
    WriteByte(enabled ? 1 : 0);

    char value = ReadByte();
    SynchInput(value);

    if(value != parameter)
    {
        SynchInput(value);
        throw std::runtime_error("Response is not synchronized");
    }
}

size_t CyberGlove::SendCommand(const char* command, char* response, size_t responseMaxLength)
{
    WriteCommand(command);

    char value = ReadByte();

    size_t length = 0;
    if(response)
    {
        for(length = 0; length < responseMaxLength && value; ++length)
        {
            response[length] = value;
            value = ReadByte();
        }

        if(length < responseMaxLength)
            response[length] = '\0';
    }

    // Read the rest of the command
    SynchInput(value);

    return length;
}

unsigned char CyberGlove::QueryByte(const char* command)
{
    WriteCommand(command);

    char result = ReadByte();

    SynchInput();

    return result;
}

void CyberGlove::GetSample(unsigned char *sample, size_t size, unsigned int *timeStamp)
{
    if(!isStreaming)
    {
        WriteByte(Control::GetSingleSample);
        char value = ReadByte();
        if(value != Control::GetSingleSample)
            throw std::runtime_error("Input not synchronized");
    }
    else
    {
        char value = ReadByte();
        if(value != Control::StreamSamples)
            throw std::runtime_error("Input not synchronized");
    }

    // Number of samples to be read into the destination
    size_t sampleCount = std::min(size, sampleSize);

    // Read the samples into the destination
    for(size_t idx = 0; idx < size; ++idx)
        sample[idx] = ReadByte();

    // If more samples than available were requested, set them to 0
    for(size_t idx = sampleCount; idx < size; ++idx)
        sample[idx] = 0;

    // Read time-stamp    
    if(timeStamp)
        *timeStamp = 0;

    if(timeStampsEnabled && timeStamp)
    {
        // Flush any unneeded samples so we can get the time stamp
        for(size_t idx = size+1; idx < sampleSize; ++idx)
            ReadByte();

        unsigned char nulEncoding = ReadByte();
        *timeStamp|= (ReadByte() ^ (nulEncoding & 1));
        *timeStamp|= (ReadByte() ^ (nulEncoding & 2)) << 8;
        *timeStamp|= (ReadByte() ^ (nulEncoding & 4)) << 16;
        *timeStamp|= (ReadByte() ^ (nulEncoding & 8)) << 24;
    }

    // TODO: Read glove-status
    
    // Handle errors

    SynchInput();
}

void CyberGlove::StartStreaming()
{
    WriteByte(Control::StreamSamples);
    isStreaming = true;
}

void CyberGlove::StopStreaming()
{
    WriteByte(Control::Cancel);

    ClearInput();

    isStreaming = false;
}

void CyberGlove::TimeStamp(bool enabled) { SetParameter(Parameter::TimeStamp, enabled); timeStampsEnabled = enabled; }

bool   CyberGlove::IsGloveConnected()   { return (bool)QueryByte(Query::GloveValid); }
bool   CyberGlove::IsRightHanded()      { return (bool)QueryByte(Query::RightHanded); }
size_t CyberGlove::SensorCount()        { return sensorCount; }
size_t CyberGlove::SampleSize()         { return sampleSize; }











