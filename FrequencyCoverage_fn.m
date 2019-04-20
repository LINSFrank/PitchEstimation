function [cfs, numchans] = FrequencyCoverage_fn(low_cf,high_cf,etaC)
%  
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
% This function calculates of the gammatone auditory filterbank: center
% frequencies and number of subbands, according to the provided frequency
% range and frequency coverage metric. Details can be found in Paper 1.

    D = 24.7; E = 0.108;
    kn = @(n) 2* sqrt(2^(1/n)-1) * (pi* factorial(2*n-2)*2^(-(2*n-2))/(factorial(n-1)).^2)^(-1);
    k4 = kn(4);

    numchans = floor( 1 + log( (D+E*high_cf)/(D+E*low_cf)) / log( (E*k4+2*etaC)/(-E*k4+2*etaC) ) );
    
    Dp = E/D; Ep = 1/(E+log10(exp(1)));
    Upsilon = @(f) Ep* log10(1+Dp*f);
    Ups_cfs = linspace(Upsilon(low_cf), Upsilon(high_cf), numchans);
    cfs = (10.^(Ups_cfs/Ep)-1)/Dp;
    
    
end
