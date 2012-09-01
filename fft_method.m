clear all;
close all;
clc
%Sampling Frequency
fs = 250e6;
Ts = 1/fs;
t = 0:Ts:1e-6;
%Center Frequency
fc = 70e6;
%Moving Average Filter
lpf = ones(1,16);
lpf = lpf/length(lpf);
%noise coefficient
n = 0.1;
%Threshold values for Schmitt Trigger
thr_high = 0.5;
thr_low = thr_high * 0.8;
%First Signal
x1= cos(2 * pi * fc * t) + (n * randn(1, length(t)));
%Delay
delay = 0.5e-9;
%Delayed Signal 
x2 = cos(2 * pi * fc *(t + delay)) + (n * randn(1, length(t)));

figure()
subplot(2, 1, 1);
plot(t, x1, 'g')
title('Original Signal')
subplot(2, 1, 2);
plot(t, x2, 'r')
title('Delayed Signal')

numberofPoints = ceil((length(t) + 1) / 2);% numberofPoints is 126
f = ((0:numberofPoints - 1) * fs) / length(t);

figure(1)
subplot(2, 1, 1),plot(x1)
subplot(2, 1, 2),plot(x2)
fftFirstSignal = fft(x1);
fftSecondSignal = fft(x2);

%MAGNITUDERESPONSEPART
figure(2)
subplot(2, 1, 1);
plot(f, abs(fftFirstSignal(1:numberofPoints)));
title('First Transformation : Magnitude response');
subplot(2, 1, 2)
plot(f, abs(fftSecondSignal(1:numberofPoints)));
title('Second Transformation : Magnitude response')

%PHASE RESPONSE PART
figure(3)
subplot(2, 1, 1),plot(f, angle(fftFirstSignal(1:numberofPoints)));
title('Phase Response of First Transformation');
subplot(2, 1, 2),plot(f, angle(fftSecondSignal(1:numberofPoints)));
title('Phase Response of Second Transformation');

%taking consideration into maximum points of the signals
%by doing that we ignore the rest of the signal
%but just maximum points in comparison
[magnitudeofFirstSignal indexofFirstSignalAmplitude] = max(abs(fftFirstSignal));
[magnitudeofSecondSignal indexofSecondSignalAmplitude] = max(abs(fftSecondSignal));

phaseofFirstSignal = angle(fftFirstSignal(indexofFirstSignalAmplitude));
phaseofSecondSignal = angle(fftSecondSignal(indexofSecondSignalAmplitude));
phaseLag = phaseofFirstSignal - phaseofSecondSignal

timeDelay= abs(phaseLag)/((fc)*2*pi)
%ratio of second signal to first signal, amplitudewise.
amplitudeRatio = magnitudeofSecondSignal/magnitudeofFirstSignal;



