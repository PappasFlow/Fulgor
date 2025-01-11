%Ejercicio 3C
clear;      % Clear all variables
close all;  % Close all figures
clc;        % Clear command window
f = 150e6;
n_samples = 100;
OVR = 256;
%Datos de seÃ±al discreta
fs_disc = 400e6;
t_disc = (0:n_samples-1) * 1/fs_disc;
%Se aumenta la amplitud para visualizar mejor en FFT
tone_disc = cos(2*pi*f * t_disc); 

%Delay en segundos
time_delay = 390.625e-12;

%Delay Fraccionario con sinc
frac_delay=time_delay * fs_disc;
n_taps=257; 
[tone_disc_delay, h] = fractional_delay(tone_disc, frac_delay, n_taps);

%Delay Fraccionario con rcos
beta = 0.1; % Rolloff
h2= my_rcosine(1,1,beta,n_taps,frac_delay);
group_delay = (n_taps-1)/2;
yf = filter(h2,1,[transpose(tone_disc); zeros(group_delay,1)]); % Agrego zeros para mantener el largo de la senial filtrada
yf = transpose(yf(group_delay+1:end)); % Corrijo el retardo de grupo

%Setup FFT
NFFT=OVR*n_samples;

len_disc = length(tone_disc);

tone_disc_fft = fftshift(abs(fft(tone_disc, NFFT))/len_disc);
tone_disc_delay_fft = fftshift(abs(fft(tone_disc_delay, NFFT))/len_disc);
yf_fft = fftshift(abs(fft(yf, NFFT))/len_disc);
h_fft=fftshift(abs(fft(h,NFFT)));
h2_fft=fftshift(abs(fft(h2,NFFT)));

f_disc = (-NFFT/2:NFFT/2-1)*fs_disc/NFFT;

%Plot en frecuencia
figure
hold on
grid on
f1 = plot(f_disc/1e6,tone_disc_fft, 'r');
f2 = plot(f_disc/1e6,tone_disc_delay_fft, 'b');
f3 = plot(f_disc/1e6,yf_fft,'c');
f4 = plot(f_disc/1e6,h_fft, 'k');
f5 = plot(f_disc/1e6,h2_fft, 'm');
legend([f1, f2, f3, f4, f5], 'Señal discreta', 'Señal discreta con retardo con sinc',...
                            'Señal discreta con retardo con rcos', 'Filtro sinc',...
                            'Filtro rcos');
xlabel('Frecuencia (MHz)');
ylabel('Amplitud');
title('Señales y respuesta en frecuencia del filtro');
xlim([-200,200]);