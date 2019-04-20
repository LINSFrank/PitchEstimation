function [x, f0p, Config] = SinglePitchEstimatorKeele_fn(apath, afilename, SNR, Noise, Config )
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
%% Signal - harmonic structure;
fs = Config.fs; % sampling frequency.
[x1,fsraw] = audioread([apath,afilename]); % raw sound file.
x1 = x1(1:(length(x1)),:);
x2 = resample(x1, fs, fsraw);
x2 = x2(:);

[nnoise, fs_noise] = audioread(['Aurora\', Noise{1}, '.wav']);
nnoise = resample(nnoise, fs, fs_noise); % must have same sample rate.
nnoise = repmat(nnoise, [5,1]); % noise may be shorter than sound file.
AmpNoise = 10^(-SNR/20) * norm(x2)/norm(nnoise(1:length(x2)));
nnoiseA = AmpNoise*nnoise(1:length(x2));
x = x2 +nnoiseA;
Len = length(x);



%% Subband Encoding
low_cf = Config.f0_min;
high_cf = 1270; 
nmax = ceil(fs/Config.f0_min);
nmin = floor(fs/Config.f0_max);
[cfs, numchans] = FrequencyCoverage_fn(low_cf,high_cf, Config.etaC);
[bm, ~] = gammatoneFast(x, cfs, fs, true); %
[ps2, hs2] = genSpikesPitchPks_fn(bm);
nbm = 5; % Chosen as in the paper. 
dr = 1; % Chosen as in the paper. 
hn2 = zeros(size(ps2));

for b = 1:numchans
    nb = 1:nbm; 
    stmp0 = exp(-nb*dr);
    stmp = [fliplr(stmp0),1,stmp0];
    hn2(:,b) = conv(hs2(:,b), stmp, 'same'); % encoding spikes.
end


% 
%% Auditory Filterbank and Spikes + ACF
tacorr = 1/Config.f0_min; % to avoid alias. length for corrlation must be at least twice as much.
nacorr = round( ceil(tacorr *fs) ); 
if nmax > nacorr*2
    disp('===============error: nmax>nacorr: (max time delay greater than frame size)!!!==========================')
    pause
end
Nm = floor(Len/nacorr)-1; % number of frames
Aacr = zeros(numchans, Nm, nmax-nmin+1);



for n = 1:Nm
%% matrix way of doing autocorrelation
% shifted data
    for b = 1: numchans 
        sig0 = hn2((n-1)*nacorr+1 : (n+1)*nacorr, b );
        sig = sig0 - mean(sig0);
        xmat=convmtx(sig,nmax);
        xsft=xmat(1:end-nmax+1,nmin:nmax);
        
        if any(sig ~= 0)
            revden = 1/(norm(sig)^2);
        else
            revden = 0;
        end
        Aacr(b,n,:)  = xsft' * sig * revden ; % 
    end

end

%% Find Peaks
Aacr(Aacr<0) = 0;
sumA = 20*log10( squeeze(mean(Aacr,1)));
sumA(sumA<-40) = -40;

Config.Len = Len;
Config.nacorr = nacorr; 
sumA_thresh = -18; % Chosen as in the paper. 
f0p = cell(Nm,1);
taup = zeros(Nm,1);
for n = 1:Nm
    [~,ind] = findpeaks(sumA(n,:), 'SORTSTR', 'DESCEND', 'NPEAKS', 1, 'MINPEAKHEIGHT', sumA_thresh);
    if size(ind)>0
        taup(n) = min(ind) + nmin-1;
        f0p{n} = fs/taup(n);
    end
end


end







