%---------------------------------------------------%
%%% General Config as done in TinyRad examples %%%
%---------------------------------------------------%
clear;
close all;

% Configure script
Disp_FrmNr = 0;
Disp_TimSig = 0;
Disp_FFT = 0;
Disp_Heart_Breathing_Rate = 1;

% Speed of light const
c0 = 299792458;

% Directories
CurPath = pwd();
addpath([CurPath,'/../../DemoRadUsb']);
addpath([CurPath,'/../../Class']);

% Setup Connection
Brd = TinyRad();
Brd.BrdRst();

% Software Version
Brd.BrdDispSwVers();

% Configure Receiver
Brd.RfRxEna();
TxPwr = 100;

% Configure Transmitter (Antenna 0 - 2, Pwr 0 - 100)
Brd.RfTxEna(1, TxPwr);

% Read calibration data from the EEPROM
CalDat = Brd.BrdGetCalDat();
CalDat = CalDat(1:4);

% Configure Up-Chirp and timing for the measurements
Cfg.fStrt = 24.00e9;   % Start frequency   
Cfg.fStop = 24.25e9;   % Stop frequency
Cfg.TRampUp = 256e-6;  % UpChirp duration
Cfg.Perd = 1e-3;       % Period between measurements
Cfg.N = 256;           % Number of samples taken at start of chirp 
Cfg.Seq = [1];         % Antenna transmit sequence
Cfg.CycSiz = 2;        % Number of buffers in the acquisition framework 2
Cfg.FrmSiz = 200;      % Number of chirp sequences for one measurement cycle
Cfg.FrmMeasSiz = 1;    % Number of chirps sequences for collecting IF data

Brd.RfMeas(Cfg);

pause(0.5);

% Read actual configuration
NrChn = Brd.Get('NrChn');
N = Brd.Get('N');
fs = Brd.Get('fs');

% Variables
NFFT = 2^12;
kf = (Cfg.fStop - Cfg.fStrt)/Cfg.TRampUp;
vRange = [0:NFFT/2-1].'./NFFT.*fs.*c0/(2.*kf);

% Min & max heart and breathing rates
rate_min = 0.1;  % 6 bpm = 0.1 Hz
rate_max = 1;  % 60 bpm = 1 Hz

% Bandpass filter
bandpass_filter = designfilt('bandpassiir', 'FilterOrder', 4, ...
                                'HalfPowerFrequency1', rate_min, ...
                                'HalfPowerFrequency2', rate_max, ...
                                'SampleRate', fs);

% Distance of human from radar to detect heart rate (in meters)
distance_min = 0.5;
distance_max = 1.5;
[~, distance_min_idx] = min(abs(vRange - distance_min));
[~, distance_max_idx] = min(abs(vRange - distance_max));

% arrays to store signal values
DetectedSignal = [];

%---------------------------------------------------%
%%% Collecting Data %%%
%---------------------------------------------------%
disp('Collecting data...');

% collect data
for i = 1:100
    Data = Brd.BrdGetData();

    % display values collected
    if Disp_FrmNr > 0
        disp(num2str(Data(1,:)))
    end

    Data = Data(2:end,:);

    %calculate FFT
    DataFFT = fft(Data, NFFT);
    Phase = angle(DataFFT(1:NFFT/2, :));

    % Get the strongest signal within 0.5-1.5 meters
    [~, max_signal] = max(mean(Phase(distance_min_idx:distance_max_idx,:), 2));
    RangeBin = distance_min_idx + max_signal - 1;
    ComplexVal = DataFFT(RangeBin, :);
    MergedComplex = mean(ComplexVal);

    PhaseSignal = unwrap(angle(MergedComplex));

    % Apply bandpass filters
    filtered_signal = filter(bandpass_filter, PhaseSignal);
    DetectedSignal = [DetectedSignal; PhaseSignal];

    time = (0:length(DetectedSignal)-1)/5;
    
    % Raw Signal Output
    if Disp_TimSig > 0      
        figure(1)
        plot(Data(:,:));
        grid on;
        xlabel('Sample');
        ylabel('Amplitude');   
        legend('Channel 1', 'Channel 2', 'Channel 3', 'Channel 4');
        title('Raw Radar Data')
    end

    % FFT Output
    if Disp_FFT > 0    
        figure(2);
        plot(vRange, Mag);
        grid on;
        xlabel('Range (m)');
        ylabel('Amplitude');
        legend('Channel 1', 'Channel 2', 'Channel 3', 'Channel 4');
        title('FFT Data')
    end

    % Breathing & Heart Rate Output
    if Disp_Heart_Breathing_Rate > 0
        figure(3);
        plot(time, DetectedSignal);
        grid on;
        xlabel('Time (s)');
        ylabel('Phase');
        title('Filtered Signal');
    end

    drawnow();
end

%---------------------------------------------------%
%%% Get Bpm Values %%%
%---------------------------------------------------%
% FFT to get frequency
L = length(DetectedSignal);
f_axis = (0:L-1)*fs/L;
PhaseFFT = abs(fft(DetectedSignal - mean(DetectedSignal)));

% Find peak frequency in the valid frequency range (less than 2 Hz)
valid_idx = f_axis < 2;
[max_val, peak_idx] = max(PhaseFFT(valid_idx));
peak_freq = f_axis(valid_idx);
dominant_freq = peak_freq(peak_idx);s

% Convert to BPM
dominant_bpm = dominant_freq * 60;

% Heart Rate Output
fprintf('Estimated Heart Rate: %.2f BPM\n', dominant_bpm);
