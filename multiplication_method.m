clear all;
close all;
clc
%Initialization of given constants
fs = 250e6;
Ts = 1/fs;
t = 0:Ts:1e-6;
fc = 70e6;

%Moving Average Filter
lpf = ones(1,16);
lpf = lpf/length(lpf);
freqz(lpf)
%Noise Constant
n = 0.1;
%Delay
delay = 0.5e-9;
%Constants for Schmitt Trigger
thr_high = 0.5;
thr_low = thr_high*0.8;

%Defining Signals
x1 = cos(2*pi*fc*t)+(n*randn(1,length(t)));
x2 = cos(2*pi*fc*(t+delay))+(n*randn(1,length(t)));

figure(1)
plot(t, x1, 'b')
hold on
plot(t, x2, 'r')
title('Signals')
%Multiplication of  two signals
multipleofTwoSignals = x1 .* x2;

%1/2 cos(x+y)          1/2 cos(x-y)
%1/2 cos(4*pi*fc*(t+delay)    1/2 cos(2*pi*fc*delay)
%Applying filter to multiple of two signals in order to get 
%low frequency component
%To erase the coefficient of 1/2 in the multiplication
%need to multiply with two and process moving average filter
filteredMultipleSignal = 2 * filter(lpf, 1, multipleofTwoSignals);
figure(2)
plot(t, filteredMultipleSignal, 'b')
title('Filtered Multiplied Signal')
binaryFilteredMultipleSignal = zeros(1, length(filteredMultipleSignal));

%To get the 2*pi*fc part of the signal
%need to inverse cosine function
inverseofFilteredMultipleSignal = acos(filteredMultipleSignal);

%To get the delay in inversecosine 
%need to divide by 2*pi*fc
findTime = inverseofFilteredMultipleSignal / (2 * pi * fc);

delayTime = abs(mean(findTime))
figure(3)
plot(inverseofFilteredMultipleSignal, 'r')
title('Inverse of Filtered Multiplied Signal')
figure(4)
plot(findTime, 'g')
title('Time')
%Schmitt Trigger
for i = 2:length(filteredMultipleSignal)
    if(binaryFilteredMultipleSignal(i-1) == 1)
        if(filteredMultipleSignal(i) < thr_low)
            binaryFilteredMultipleSignal(i) = 0;
        else
            binaryFilteredMultipleSignal(i) = 1;
        end
    else
        if(filteredMultipleSignal(i)>thr_high)
            binaryFilteredMultipleSignal(i)=1;
        else
            binaryFilteredMultipleSignal(i)=0;
        end
    end
end   

figure(5)
plot(binaryFilteredMultipleSignal, 'b')
title('Schmitt Triggered Multiplied Signal')

