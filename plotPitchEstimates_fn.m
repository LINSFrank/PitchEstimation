function plotPitchEstimates_fn(apath, filename, x, f0, SNR, Noise, Config)
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

%% Load Ground Truth
load([apath, filename(1:end-4), '.mat']);
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
export_fig([Config.bpath, filename, '_PitchEstimates_SNR=',num2str(SNR), '_Noise=', Noise{1}, '.pdf']);


