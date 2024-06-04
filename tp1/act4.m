clear;      % Clear all variables
close all;  % Close all figures
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

plot(w_v, 0.707,'--r','Linewidth',4); %genera una linea a -3db pero en veces

% Configuración de los ejes y etiquetas
xlim([0, pi]) % Analizaremos solo w > 0
title('[Act. 4F] Barrido en \alpha magnitud de la respuesta en frecuencia');
xlabel('Frecuencia [rad/s]')
ylabel('Modulo H(e^{j\omega})')
grid on;

% Leyenda de la gráfica
legend('\alpha = 0.5','\alpha = 0.6','\alpha = 0.7','\alpha = 0.8','\alpha = 0.9','\alpha = 0.99','-3db','Location', 'best');

%% act 4 g

% Parámetros
alpha = 0.95;
M = 100;

%filtro IIR
H_IIR = (1-alpha)./(1-alpha.*exp(-j.*w_v));

%filtro FIR
h_v = 1/(M+1).*ones(M+1,1); %ones crea matris (M2+1)x1 de valor 1
%h_v = 1/M.*ones(M,1); %ver si no es asi
% Respuesta en frecuencia utilizando FFT
H_FIR = fft(h_v, POINTS);
H_FIR = fftshift(H_FIR);



% Gráfico de H_FIR vs H_IIR
figure;
plot(w_v, abs(H_FIR), '-r', 'Linewidth', 2);
hold on;
plot(w_v, abs(H_IIR), '--b', 'Linewidth', 2);
hold on;
plot(w_v, 0.707,'--k','Linewidth',4); %genera una linea a -3db pero en veces

xlim([0, pi]) % Analizaremos solo w > 0
title('[Act. 4f] Modulo FIR vs IRR');
xlabel('Frecuencia [rad/s]')
ylabel('Modulo H(e^{j\omega})')
legend('FIR', 'IIR','-3db');
grid on;
