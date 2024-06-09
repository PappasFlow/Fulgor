clear;      % Clear all variables
%%close all;  % Close all figures
clc;        % Clear command window
%% act 4 d

POINTS = 1024; % Resolución 
alpha = 0.8;  % definimos alpha

% definimos de -pi a pi un vector con POINTS elementos
w_v = -pi : 2*pi/POINTS : pi-2*pi/POINTS;

n_v = [0:POINTS-1]; %vector poins elementos

% Respuesta en frecuencia obtenida analíticamente
H_a = (1-alpha)./(1-alpha.*exp(-j.*w_v));

% Respuesta al impulso obtenida
h = (1-alpha).*alpha.^n_v;

% Cálculo de la respuesta en frecuencia utilizando FFT
H_fft = fftshift(fft(h, POINTS));

% Gráfico de H_a vs H_fft
figure;
subplot(211); %modulo
plot(w_v, abs(H_fft), '-r', 'Linewidth', 2);
hold on;
plot(w_v, abs(H_a), '--b', 'Linewidth', 2);
title('[Act. 4D] Modulo y Fase');
xlabel('Frecuencia [rad/s]')
ylabel('Modulo H(e^{j\omega})')
legend('fft', 'Analitico');
grid on;

subplot(212); %Fase
plot(w_v, angle(H_fft), '-r', 'Linewidth', 2);
hold on;
plot(w_v, angle(H_a), '--b', 'Linewidth', 2);
xlabel('Frecuencia [rad/s]')
ylabel('Fase H(e^{j\omega})')
legend('fft', 'Analitico');
grid on;

%% act 4 F
figure;
hold all; %asi se logra q se mantengan graf y cambien color

% Iterar sobre diferentes valores de M2
for alpha = [0.5, 0.6, 0.7, 0.8, 0.9, 0.99]
    % Respuesta en frecuencia obtenida analíticamente
    H_a = (1-alpha)./(1-alpha.*exp(-j.*w_v));
    
    plot(w_v, abs(H_a), 'LineWidth', 2);
end

hold on;
plot(w_v, 0.707 * ones(size(w_v)), '--r', 'LineWidth', 1); % Genera una línea a -3 dB

% Configuración de los ejes y etiquetas
xlim([0, pi]) % Analizaremos solo w > 0
title('[Act. 4F] Barrido en \alpha magnitud de la respuesta en frecuencia');
xlabel('Frecuencia [rad/s]')
ylabel('Modulo H(e^{j\omega})')
grid on;

% Leyenda de la gráfica
legend('\alpha = 0.5','\alpha = 0.6','\alpha = 0.7','\alpha = 0.8','\alpha = 0.9','\alpha = 0.99','-3db','Location', 'best');

%% act 4 G
% Parámetros
alpha = 0.95;
M = 50; % Valor inicial de M
POINTS = 1024; % Número de puntos para la FFT
w_v = linspace(-pi, pi, POINTS);

% filtro IIR
H_IIR = (1-alpha)./(1-alpha.*exp(-1j.*w_v));

% filtro FIR
h_v = 1/(M+1).*ones(M+1,1); % ones crea matriz (M+1)x1 de valor 1
H_FIR = fft(h_v, POINTS);
H_FIR = fftshift(H_FIR);

% Calcular las magnitudes
mag_H_FIR = abs(H_FIR);
mag_H_IIR = abs(H_IIR);

% Línea de -3dB
linea_3db = 0.707;

% Gráfico de H_FIR vs H_IIR
figure;
plot_handle = plot(w_v, mag_H_FIR, '-r', 'Linewidth', 2);
hold on;
plot(w_v, mag_H_IIR, '--b', 'Linewidth', 2);
plot(w_v, linea_3db*ones(size(w_v)), '--k', 'LineWidth', 1);

% Encontrar puntos de cruce
% FIR
cruces_FIR = find(diff(sign(mag_H_FIR - linea_3db)) ~= 0);
% IIR
cruces_IIR = find(diff(sign(mag_H_IIR - linea_3db)) ~= 0);

% Interpolación lineal para encontrar los cruces con mayor precisión
frecuencias_cruce_FIR = [];
for i = 1:length(cruces_FIR)
    idx = cruces_FIR(i);
    w_cruce = interp1(mag_H_FIR(idx:idx+1) - linea_3db, w_v(idx:idx+1), 0);
    frecuencias_cruce_FIR = [frecuencias_cruce_FIR, w_cruce];
end

frecuencias_cruce_IIR = [];
for i = 1:length(cruces_IIR)
    idx = cruces_IIR(i);
    w_cruce = interp1(mag_H_IIR(idx:idx+1) - linea_3db, w_v(idx:idx+1), 0);
    frecuencias_cruce_IIR = [frecuencias_cruce_IIR, w_cruce];
end

% Calcular las diferencias
diferencias_fir = diff(frecuencias_cruce_FIR);
diferencias_iir = diff(frecuencias_cruce_IIR);

% Crear cadenas para la leyenda
leyenda_fir = sprintf('AB FIR %.3f', diferencias_fir);
leyenda_iir = sprintf('AB IIR %.3f', diferencias_iir);

% Mostrar los puntos de cruce en el gráfico
plot(frecuencias_cruce_FIR, linea_3db * ones(size(frecuencias_cruce_FIR)), 'or', 'Linewidth', 2);
plot(frecuencias_cruce_IIR, linea_3db * ones(size(frecuencias_cruce_IIR)), 'ob', 'Linewidth', 2);

xlim([0, pi]) % Analizaremos solo w > 0
title('[Act. 4G] Módulo FIR vs IIR');
xlabel('Frecuencia [rad/s]')
ylabel('Módulo H(e^{j\omega})')

% Leyenda del gráfico incluyendo las diferencias
leyenda_handle = legend('FIR', 'IIR', '-3dB', leyenda_fir, leyenda_iir);
grid on;

