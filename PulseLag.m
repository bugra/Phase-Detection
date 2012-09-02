
clear all;
close all;
clc
%Sampling Frequency
fs = 250e6;
Ts = 1 / fs;
t = 0:Ts:1e-6;
%Center Frequency
fc = 70e6;
fc_down = 68e6;
%Moving Average Filter
lpf = ones(1, 16);
lpf = lpf / length(lpf);
%Noise Coefficient
n = 0.2;
thr_high = 0.5;
thr_low = thr_high * 0.8;
%Delay
delay = 0.5e-9;
%Building a DC signal to crop the signal
x_dc= cos(2 * pi * fc_down * t);
x1 = cos(2 * pi * fc * t) + (n * randn(1, length(t)));
x2 = cos(2 * pi * fc * (t + delay)) + (n * randn(1, length(t)));

figure(1)
plot(t, x1, 'b')
hold on
plot(t, x2, 'r')
title('Signal and delayed signal')

%Multiplexer of the signal
x1_dc = x1 .* x_dc;
x2_dc = x2 .* x_dc;

x1_dc_lpf = 2 * filter(lpf, 1, x1_dc);
x2_dc_lpf = 2 * filter(lpf, 1, x2_dc);
figure(2)
plot(t, x1_dc_lpf, 'b')
hold on
plot(t, x2_dc_lpf, 'r')
title('Filtered Signals')
x1_dc_lpf_sql = zeros(1, length(x1_dc_lpf));
x2_dc_lpf_sql = zeros(1, length(x2_dc_lpf));

%Schmitt Trigger
for i = 2:length(x1_dc_lpf)
    if(x1_dc_lpf_sql(i-1) == 1)
        if(x1_dc_lpf(i) < thr_low)
            x1_dc_lpf_sql(i) = 0;
        else
            x1_dc_lpf_sql(i) = 1;
        end
    else
        if(x1_dc_lpf(i) > thr_high)
            x1_dc_lpf_sql(i) = 1;
        else
            x1_dc_lpf_sql(i) = 0;
        end
    end
    
    if(x2_dc_lpf_sql(i-1) == 1)
        if(x2_dc_lpf(i) < thr_low)
            x2_dc_lpf_sql(i) = 0;
        else
            x2_dc_lpf_sql(i) = 1;
        end
    else
        if(x2_dc_lpf(i) > thr_high)
            x2_dc_lpf_sql(i) = 1;
        else
            x2_dc_lpf_sql(i) = 0;
        end
    end
end
figure(3)
plot(x1_dc_lpf_sql, 'b')
hold on
plot(x2_dc_lpf_sql, 'r')
title('Schmitt Triggered Signals')


differenceFirstSignalCounter = 0;
differenceSecondSignalCounter = 0;
oneCounter = 0;
zeroCounter = 0;
temp = zeros(1, (length(x1_dc_lpf_sql)));

for i = 2:(length(x1_dc_lpf_sql))
    if(x1_dc_lpf_sql(i) == 1 && x2_dc_lpf_sql(i) == 0)
        differenceFirstSignalCounter = differenceFirstSignalCounter + 1;
    elseif(x1_dc_lpf_sql(i) == 0 && x2_dc_lpf_sql(i) == 0)
        zeroCounter = zeroCounter+1;
    elseif(x1_dc_lpf_sql(i) == 0 && x2_dc_lpf_sql(i) == 1)
        differenceSecondSignalCounter = differenceSecondSignalCounter + 1;
    else
        oneCounter = oneCounter + 1;
    end
end

totalCounter = differenceFirstSignalCounter + differenceSecondSignalCounter + oneCounter + zeroCounter;
phaseLag = differenceFirstSignalCounter / totalCounter
timeDelay = phaseLag / (fc)

%DEBUG PURPOSES
differenceFirstSignalCounter;
differenceSecondSignalCounter;
oneCounter;
zeroCounter;
