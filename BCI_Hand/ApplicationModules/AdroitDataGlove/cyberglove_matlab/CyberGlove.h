
#include <string>
#include <vector>
#include <windows.h>

class CyberGlove
{
public:
    typedef unsigned char uchar;

    CyberGlove(const std::string &port, int baudRate);
    ~CyberGlove();

    uchar ReadByte();
    void WriteByte(uchar value);
    void SynchInput(char value = 1);
    void ClearInput(void);
    uchar QueryByte(const char* command);
    void WriteCommand(const char* command);
    void SetParameter(const char parameter, bool enabled);
    size_t SendCommand(const char* command, char* response, size_t responseMaxLength);

    void Reset(bool hardwareReset = true);

    bool IsGloveConnected();
    bool IsRightHanded();
    size_t SensorCount();
    size_t SampleSize();

    void GetSample(uchar *sample, size_t size, unsigned int *timeStamp = NULL);
    void StartStreaming();
    void StopStreaming();

    void TimeStamp(bool enabled);

private:

    HANDLE port;

    size_t sensorCount;       // Total number of sensors
    size_t sampleSize;        // Number of sensors being sampled
    bool isStreaming;         // Whether samples are currently being streamed from the glove
    bool timeStampsEnabled;   // Whether each sample contains a time-stamp

    struct Control
    {
        // Control commands
        static const char* Reset;
        static const char Cancel;

        static const char GetSingleSample;
        static const char StreamSamples;
    };

    struct Parameter
    {
        static const char TimeStamp;
        static const char Filter;
        static const char SwitchControlsLight;
        static const char Light;
        static const char SendQuantized;
        static const char GloveStatus;
        static const char Switch;
        static const char ExternalSynch;
    };

    struct Query
    {
        static const char* BaudRate;
        static const char* Calibration;
        static const char* SoftwareSensorMask;
        static const char* SampleSize;
        static const char* ParameterFlags;
        static const char* SamplePeriod;
        static const char* GloveValid;
        static const char* Information;
        static const char* HardwareSensorMask;
        static const char* RightHanded;
        static const char* SensorCount;
        static const char* Version;
        static const char* TimeStampEnabled;
        static const char* FilterStatus;
        static const char* SwitchControlsLight;
        static const char* Light;
    };

};

