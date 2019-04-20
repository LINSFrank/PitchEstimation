% This program is provided as is, and without any warranty. 
% It is for free for non-commercial research and study purposes.
% If you find it useful, please kindly cite these papers:
% 1. Robust Pitch Estimation and Tracking for Speakers Based on Subband
%   Encoding and the Generalized Labeled Multi-Bernoulli Filter. 
%   IEEE/ACM Transactions on Audio, Speech, and Language Processing, 27(4),
%   827-841. 2019.
% 2. A New Frequency Coverage Metric and a New Subband Encoding Model, with
%   an Application in Pitch Estimation, pp. 2147-2151. Interspeech 2018. 
% !---
% ==========================================================
% Last changed:     $Date: 2019-04-20 $
% Last committed:   $Revision: 1.0 $
% Last changed by:  $Author: Shoufeng Lin $
% Author Email:     $ee.linsf@gmail.com $ 
% ==========================================================
% !---

close all;
clear;
[filename, apath] = uigetfile({'*.wav; *.mp3'},'Sound File Selector'); % Select the folder where the sound files are. 
%filename list speech sound files, or use dir function to get sound file
%names. In this example there is only one file selected. 
N = length(filename); % number of sound files to test.

Config.fs = 16000; % sound sampling frequency. 
Config.f0_min = 60; % pitch frequency range.
Config.f0_max = 500;
Config.etaC = 1; % Choose 100% frequency coverage.
Config.SNR = 20; % SNRs to be tested. 
Config.Noise = {'babble'}; % list noise sound files, or use dir function to get sound file names.
Config.Perr = 0.05; % Over 5% deviation is regarded as error. 

Config.testID = ['Pitch_Est_etaC=',num2str(Config.etaC),'Perr=', num2str(Config.Perr)];
mkdir([apath, Config.testID]);
bpath = [apath, Config.testID, '\'];
Config.bpath = bpath; 
save([bpath, 'Config.mat'], 'Config');

for k = 1:length(Config.SNR)
    SNR = Config.SNR(k);
    disp(['SNR=',num2str(SNR),'dB']);
    for m = 1:length(Config.Noise)
        tic
        Noise = Config.Noise(m);
        close all;
        smsg = strcat(filename, ', noise type is: ', Noise);
        disp(smsg);
        [x, f0, Config] = SinglePitchEstimatorCSTR_fn(apath, filename, SNR, Noise, Config );
        save([bpath, filename, '_PitchEstimates_SNR=',num2str(SNR), '_Noise=', Noise{1}, '.mat'], 'f0');
        plotPitchEstimates_fn(apath, filename, x, f0, SNR, Noise, Config);
        toc
    end
end





