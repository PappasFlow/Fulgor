%%Ejercicio 3A
clear;      % Clear all variables
close all;  % Close all figures
clc;        % Clear command window
f = 50e6;
n_samples = 100;

%Datos de seÃ±al discreta
fs_disc = 400e6;
t_disc = (0:n_samples-1) * 1/fs_disc;
tone_disc = cos(2*pi*f * t_disc);

%Datos de seÃ±al continua
OVR = 256;
fs_cont = OVR * 2 * f;
% Se divide en 4 para tener el mismo tiempo de simulaciÃ³n en los vectores
t_cont = (0:OVR/4 * n_samples-1) * 1/fs_cont; 
tone_cont = cos(2*pi*f * t_cont);

%Delay en segundos
time_delay = 390.625e-12;

%Delay AnalÃ³gico
sample_delay = time_delay * fs_cont;
tone_cont_delay = continuous_delay(tone_cont, sample_delay);

%Delay Fraccionario
frac_delay=time_delay * fs_disc;
n_taps=31; 
tone_disc_delay = fractional_delay(tone_disc, frac_delay, n_taps);

% PLOT EN TIEMPO
figure
subplot(2, 1, 1);
p1 = plot(t_cont / 1e-9, tone_cont, '-b', 'Linewidth', 1);
hold on;
grid on
p2 = stem(t_disc / 1e-9, tone_disc, 'r', 'Linewidth', 1.5);
xlabel('Tiempo (ns)');
ylabel('Amplitud');
title('Señales antes del delay');
legend([p1, p2], 'Señal continua', 'Señal discreta');
xlim([(1/f)/ 1e-9, 3 * (1/f) / 1e-9]);


subplot(2, 1, 2);
p3 = plot(t_cont / 1e-9, tone_cont_delay, '-g', 'Linewidth', 1);
hold on;
grid on
p4 = stem(t_disc / 1e-9, tone_disc_delay, 'k', 'Linewidth', 1.5);
xlabel('Tiempo (ns)');
ylabel('Amplitud');
title('Señales despues del delay');
legend([p3, p4], 'Señal continua', 'Señal discreta');
xlim([(1/f)/ 1e-9, 3 * (1/f)/ 1e-9]);