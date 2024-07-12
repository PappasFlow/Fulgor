%%Ejercicio 3B
clear;      % Clear all variables
close all;  % Close all figures
clc;        % Clear command window
f = 150e6;
n_samples = 100;

%Datos de señal discreta
fs_disc = 400e6;
t_disc = (0:n_samples-1) * 1/fs_disc;
tone_disc = cos(2*pi*f * t_disc);

%Datos de señal continua
OVR = 256;
fs_cont = OVR * 2 * 50e6; %mantiene frecuencia anterior
% Se divide en 4 para tener el mismo tiempo de simulación en los vectores
t_cont = (0:OVR/4 * n_samples-1) * 1/fs_cont; 
tone_cont = cos(2*pi*f * t_cont);

%Delay en segundos
time_delay = 390.625e-12;

%Delay Analógico
sample_delay = time_delay * fs_cont;
tone_cont_delay = continuous_delay(tone_cont, sample_delay);

%Delay Fraccionario con sinc
frac_delay=time_delay * fs_disc;
n_taps=31; 
[tone_disc_delay, h] = fractional_delay(tone_disc, frac_delay, n_taps);

%Plot en tiempo
figure
subplot(2, 1, 1);
p1 = plot(t_cont / 1e-9, tone_cont, '-b', 'Linewidth', 1);
hold on;
p2 = stem(t_disc / 1e-9, tone_disc, 'r', 'Linewidth', 1.5);
xlabel('Tiempo (ns)');
ylabel('Amplitud');
title('Señales antes del delay');
legend([p1, p2], 'Señal continua', 'Señal discreta');
xlim([(1/f)/ 1e-9, 3 * (1/f) / 1e-9]);

subplot(2, 1, 2);
p3 = plot(t_cont / 1e-9, tone_cont_delay, '-g', 'Linewidth', 1);
hold on;
p4 = stem(t_disc / 1e-9, tone_disc_delay, 'k', 'Linewidth', 1.5);
xlabel('Tiempo (ns)');
ylabel('Amplitud');
title('Señales después del delay');
legend([p3, p4], 'Señal continua', 'Señal discreta');
xlim([(1/f)/ 1e-9, 3 * (1/f)/ 1e-9]);

%Setup FFT
NFFT=OVR*n_samples;

len_disc = length(tone_disc);
len_cont = length(tone_cont);

tone_disc_fft = fftshift(abs(fft(tone_disc, NFFT))/len_disc);
tone_disc_delay_fft = fftshift(abs(fft(tone_disc_delay, NFFT))/len_disc);
tone_cont_fft = fftshift(abs(fft(tone_cont, NFFT))/len_cont);
tone_cont_delay_fft = fftshift(abs(fft(tone_cont_delay, NFFT))/len_cont);
h_fft=fftshift(abs(fft(h,NFFT)));

f_cont = (-NFFT/2:NFFT/2-1)*fs_cont/NFFT;
f_disc = (-NFFT/2:NFFT/2-1)*fs_disc/NFFT;

%Plot en frecuencia
figure
hold on
f1 = plot(f_disc/1e6,tone_disc_fft, 'r');
f2 = plot(f_disc/1e6,tone_disc_delay_fft, 'b');
f3 = plot(f_cont/1e6,tone_cont_fft,'c');
f4 = plot(f_cont/1e6,tone_cont_delay_fft, 'k');
f5 = plot(f_disc/1e6,h_fft, 'm');
legend([f1, f2, f3, f4, f5], 'Señal discreta', 'Señal discreta con retardo',...
                            'Señal continua', 'Señal continua con retardo',...
                            'Filtro');
xlabel('Frecuencia (MHz)');
ylabel('Amplitud');
title('Señales y respuesta en frecuencia del filtro');
xlim([-200,200]);