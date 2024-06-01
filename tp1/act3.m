clear;      % Clear all variables
close all;  % Close all figures
clc;        % Clear command window
%% act 3 c

POINTS = 1024; % Resolución 

% definimos de -pi a pi un vector con POINTS elementos
w_v = -pi : 2*pi/POINTS : pi-2*pi/POINTS;


% Definimos función de transferencia H(w)
H = 1/5 * (1 + exp(-1j * w_v) + ...
          exp(-2j * w_v) + exp(-3j * w_v) + ...
          exp(-4j * w_v));

% Plot del Módulo de H(w)
figure
subplot(2, 1, 1) % 2 filas 1 columna plot 1
plot(w_v, abs(H), '-r', 'LineWidth', 2)
title('[Act. 3C] Modulo y Fase');
xlabel('Frecuencia [rad/s]')
ylabel('Amplitud H(e^{j\omega})')
grid on

% Plot de la Fase de H(w)
subplot(2, 1, 2) % 2 filas 1 columna plot 2
plot(w_v, angle(H), '-b', 'LineWidth', 2)
xlabel('Frecuencia [rad/s]')
ylabel('Angulo H(e^{j\omega})')
grid on

%% act 3 d

% Definición de la respuesta al impulso
h_v = [0.2, 0.2, 0.2, 0.2, 0.2]; % Respuesta al impulso

% Respuesta en frecuencia utilizando FFT
H_fft = fft(h_v, POINTS);

% Ajustar la posición de los datos utilizando fftshift
H_fft = fftshift(H_fft);

%plots
figure;
% Graficar el Módulo de H_fft y H
subplot(2, 1, 1);
plot(w_v, abs(H_fft), '-r', 'LineWidth', 2);
hold on;
plot(w_v, abs(H), '--b', 'LineWidth', 2);
title('[Act. 3d] Modulo y Fase');
xlabel('Frecuencia [rad/s]')
ylabel('Amplitud H(e^{j\omega})')
legend('fft', 'Analitico');
grid on;

% Graficar la Fase de H1(omega) y H(omega)
subplot(2, 1, 2);
plot(w_v, angle(H_fft), '-r', 'LineWidth', 2);
hold on;
plot(w_v, angle(H), '--b', 'LineWidth', 2);
xlabel('Frecuencia [rad/s]')
ylabel('Angulo H(e^{j\omega})')
legend('fft', 'Analitico');
grid on;


%% Act 3 f

figure;
hold all; %asi se logra q se mantengan graf y cambien color

% Iterar sobre diferentes valores de M2
for M2 = [4, 8, 16, 32]
    h_v = 1/(M2+1).*ones(M2+1,1); %ones crea matris (M2+1)x1 de valor 1
    %h_v = 1/M2.*ones(M2,1); %ver si no es asi
    % Respuesta al impulso
    H = fft(h_v, POINTS);
    % Respuesta en frecuencia utilizando FFT
    H = fftshift(H);
    % Ajustar la posición de los datos utilizando fftshift
    plot(w_v, abs(H), 'LineWidth', 2);
end

% Configuración de los ejes y etiquetas
xlim([0, pi]) % Analizaremos solo w > 0
title('[Act. 3f] Barrido en M2 magnitud de la respuesta en frecuencia');
xlabel('Frecuencia [rad/s]')
ylabel('Amplitud H(e^{j\omega})')
grid on;

% Leyenda de la gráfica
legend('M2 = 4', 'M2 = 8', 'M2 = 16', 'M2 = 32', 'Location', 'best');



