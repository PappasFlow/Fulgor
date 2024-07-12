fsch = 5e9; % Frecuencia de muestreo continua
omega0 = 2*pi*150e6; % Frecuencia del tono en radianes/s
fs = 2.5 * 200e6; % Frecuencia de muestreo del conversor C/D

% Generación de la señal continua
t_continuo = 0:1/fsch:1e-6; % Vector de tiempo continuo
x_continuo = cos(omega0 * t_continuo); % Señal continua

% Diseño del filtro anti-alias de orden 256
fc = 100e6; % Frecuencia de corte del filtro anti-alias
orden = 56; % Orden del filtro
b = fir1(orden, fc/(fsch/2)); % Coeficientes del filtro

% Filtrado anti-alias
x_filtrada = filter(b, 1, x_continuo); % Aplicar el filtro a la señal continua

% Conversión C/D
t_discreto = 0:1/fs:1e-6; % Vector de tiempo discreto
x_discreto = x_filtrada(1:fsch/fs:end); % Señal discreta

% Generación de la señal discreta esperada
omega0_discreto = 2*pi*(100e6/fs); % Frecuencia discreta en radianes/muestra
x_esperada = cos(omega0_discreto * (0:length(t_discreto)-1)); % Señal esperada

% Transformadas de Fourier
NFFT = 1024;
X_continuo = fftshift(fft(x_continuo, NFFT));
X_filtrada = fftshift(fft(x_filtrada, NFFT));
X_discreto = fftshift(fft(x_discreto, NFFT));
f_continuo = (-NFFT/2:NFFT/2-1)*(fsch/NFFT);
f_discreto = (-NFFT/2:NFFT/2-1)*(fs/NFFT);

% Plots
figure;
subplot(2, 1, 1);
plot(f_continuo, abs(X_continuo));
title('Transformada de Fourier de la señal continua original');
xlabel('Frecuencia (Hz)');
ylabel('Amplitud');
subplot(2, 1, 2);
plot(f_continuo, abs(X_filtrada));
hold on;
plot(f_discreto, abs(X_discreto), 'r');
title('Transformadas de Fourier después del filtrado y conversión (Filtro Orden 256)');
xlabel('Frecuencia (Hz)');
ylabel('Amplitud');
legend('Después del filtro AA', 'Después del conversor C/D');
