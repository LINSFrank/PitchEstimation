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
[afilename, apath] = uigetfile({'*.wav; *.mp3'},'Sound File Selector'); % Select the folder where the sound files are. 
afilenames = {'rl001'}; % list speech sound files, or use dir function to get sound file names.
N = length(afilenames); % number of sound files to test.
warning('off','all');

Config.fs = 16000; % sound sampling frequency. 
Config.f0_min = 60; % pitch frequency range.
Config.f0_max = 500;
Config.etaC = 1; % Choose 100% frequency coverage.
Config.SNR = 20; % SNRs to be tested. 
Config.Noise = {'babble'}; % list noise sound files, or use dir function to get sound file names.
Config.Perr = 0.05; % Over 5% deviation is regarded as error. 
GPE_LSSAOLT = zeros(N,length(Config.SNR),length(Config.Noise));
VDE_LSSAOLT = zeros(N,length(Config.SNR),length(Config.Noise));

Config.testID = ['Pitch_Est_etaC=',num2str(Config.etaC),'Perr=', num2str(Config.Perr)];
mkdir([apath, Config.testID]);
bpath = [apath, Config.testID, '\'];

for n = 1:N
    disp(['Loop # ', num2str(n)]);
    filename = [afilenames{n}, '.wav'];
    for k = 1:length(Config.SNR)
        disp(['SNR=',num2str(Config.SNR(k)),'dB']);
        for m = 1:length(Config.Noise)
            tic
            close all;
            smsg = strcat(filename, ', noise type is: ', Config.Noise(m));
            disp(smsg);
            [x, f0, Config] = SinglePitchEstimatorKeele_fn(apath, filename, Config.SNR(k), Config.Noise(m), Config );
            toc
        end
    end
end

save([bpath, 'Config.mat'], 'Config');
save([bpath, 'f0_etaC=',num2str(Config.etaC),'Perr=',num2str(Config.Perr),'.mat'], 'f0');



%% Load Ground Truth
load([apath, afilename(1:end-4), '.mat']);
P = CSTRpitch.P;
T = CSTRpitch.T; % time of ground truth, in unit of milliseconds (ms).
fs = Config.fs; 


%% Plot Results
figure; hold on

subplot(4,1,1);
plot(x); axis tight; ylabel('Amplitude'); title('Noisy Speech Signal');
set(gca, 'XTick', 0: fs*0.2: Config.Len);
set(gca,'xticklabel',(0: 0.2: Config.Len/fs));
box on;

subplot(4,1,2);
spectrogram(x, 128, 100, 200, fs,'yaxis'); 
title('Spectrogram'); xlabel(''); 
colorbar('off');
ytickformat('%1.2f');

subplot(4,1,3); 
plot(T, P, 'g', 'linewidth', 3); % plot Ground Truth.
hold on; grid on; grid minor;
xlim([0, (Config.Len/fs*1000)]);
set(gca, 'xtick', 0: 0.2*1000: Config.Len); 
set(gca, 'xticklabel', 0: 0.2: (Config.Len/fs));
ylabel('F0 (Hz)'); title('Pitch Ground Truth');
ylim([0, Config.f0_max]);
hold off;


subplot(4,1,4); hold on
for n = 1:length(f0)
    if ~isempty(f0{n})
        plot(n,f0{n}, 'xk');
    end
end
set(gca,'ylim', [0, Config.f0_max]);
set(gca,'xlim', [0, ceil(Config.Len/Config.nacorr)]);
set(gca, 'XTick', 0: ceil(fs*0.2/Config.nacorr): floor(Config.Len/Config.nacorr));
set(gca,'xticklabel',(0: 0.2: Config.Len/fs));

title('Pitch Estimates');
xlabel('Time (s)');
ylabel('F0 (Hz)');
box on
grid off
grid minor
hold off

set(gcf,'color','white');
export_fig([bpath, 'PitchEstimates.pdf']);


