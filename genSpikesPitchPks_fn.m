function [pn, hn] = genSpikesPitchPks_fn(bm)
% find the local peaks between zero-crossings.
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
Len = size(bm,1);
numchans = size(bm,2);

bm_win = bm;
bm_win(bm_win<0) = 0;
bm_win(bm_win>0) = 1;
un = 1; dn = 0;
pn = zeros(size(bm));
hn = zeros(size(bm));


for b = 1:numchans
    for t= 2:Len
        if bm_win(t,b) == 1
            if bm_win(t-1,b) == 0
                un = t;
            end
        elseif bm_win(t-1,b) == 1
            dn = t-1; % 
            if dn >= un % 
                [pk, loc] = max(bm(un:dn,b)); % 
                pn(loc+un-1,b) = 1; % 
                hn(loc+un-1,b) = pk;%
            end
        end
    end
end


end


