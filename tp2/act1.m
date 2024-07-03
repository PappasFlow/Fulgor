clear;      % Clear all variables
close all;  % Close all figures
clc;        % Clear command window
%TP2
%% Ejercicio 1

%config
w0 = 0.1*pi; %frec señal discreta
K=2; %Amplitud del tono
fs = 100e6; %frec muestreo
OVR = 10; % Oversampling factor
Nsamples=256; 
sp=2; %numero de siclos que seran ploteados 
filtro=2;
%end config

fch = OVR * fs; % Frecuencia de muestreo del tiempo continuo
Ts=1/fs; %periodo sampleo discreto
Tch=1/fch; %periodo sampleo continuo
T_tone=(2*pi)/(w0*fs);% Periodo del Tono 

t_dis_v = (0:Nsamples-1).*Ts; %vector tiempo discreto
t_con_v = (0:Nsamples*OVR-1).*Tch; %vector tiempo continuo

tone_dis = K * cos(w0*fs.*t_dis_v); %tono discreto
tone_con = K * cos(w0*fs.*t_con_v); %tono continuo de referencia

% Upsampling
tone_dis_up = upsample(tone_dis, OVR);

% Reconstruction filter selector
switch filtro
    case 1
        % Retenedor de orden cero (ZOH)
        dac_filter = ones(1,OVR);
        grpd=0; % ajustes delay del filtro
        disp('Retenedor de orden cero (ZOH)');
    case 2
        % Interpolación lineal (retenedor orden 1)
       dac_filter=1/OVR*conv(ones(1,OVR),ones(1,OVR)); 
       grpd=OVR-1;
       disp('Interpolación lineal (retenedor orden 1)');
    case 3
        % Reconstrucción ideal (filtro sinc)
        nfilt=-1000:1000;
        dac_filter = sinc(nfilt/Ts*Tch); 
        grpd = grpdelay(dac_filter);
        grpd =grpd(1);
        disp('Reconstrucción ideal (filtro sinc)');
    case 4
        % Filtro FIR personalizado
        Nord = 64; %ajuste del fir
        dac_filter =OVR * fir1(Nord, fs / fch);
        grpd=Nord/2;
        disp('Filtro FIR personalizado');
    otherwise
            disp('Filtro no valido');
            return; %corta ejecucion 
end

% filtro
x_tc1 = filter(dac_filter,1,tone_dis_up);
x_tc = [x_tc1(grpd+1:end) zeros(1, grpd)];

%%

%Plote del tiempo D/C
figure
hold all
plot(t_dis_v*1e9, tone_dis,'o','MarkerSize',6,'MarkerFaceColor','b','MarkerEdgeColor','k'); %discreto
plot(t_con_v*1e9, x_tc,'-', 'LineWidth',2); %filtrado
plot(t_con_v*1e9, tone_con,'--k', 'LineWidth',1.5); %continuo 
xlim([0,sp*T_tone*1e9])
xlabel('Time [ns]', 'Interpreter','latex','FontSize', 12);
ylabel('Amplitude [V]', 'Interpreter','latex','FontSize', 12);
grid on
legend('Discrete samples', 'Salida D/C','signal Reference');
title('[Act. 1] analisis temporal conversor D/C');

%Plote del tiempo extra 
figure
hold all
stem(t_dis_v*1e9, tone_dis,'o','MarkerSize',6,'MarkerFaceColor','b','MarkerEdgeColor','k'); %discreto
plot(t_con_v*1e9, tone_con,'--k', 'LineWidth',1.5); %continuo 
xlim([0,sp*T_tone*1e9])
xlabel('Time [ns]', 'Interpreter','latex','FontSize', 12);
ylabel('Amplitude [V]', 'Interpreter','latex','FontSize', 12);
grid on
legend('Discrete samples','signal Reference');
title('[Act. 1] Samples vs. signal Reference');
%%

% Plot en frecuencia
NFFT = 256*1024;
fvec_tc = (0:NFFT-1)/NFFT*fch;
fvec_td = (0:NFFT-1)/NFFT*fs;

W0 = hamming(length(tone_dis))';
W1 = hamming(length(tone_dis_up))';
W2 = hamming(length(tone_con))';
Ns = length(tone_dis);
spect_disc = 1/Ns*abs(fft(W0.*tone_dis, NFFT));
spect_x_up = 1/Ns*abs(fft(W1.*tone_dis_up, NFFT));
spect_tc =   1/Ns*1/OVR*abs(fft(W1.*x_tc, NFFT));
spect_tone_con =   1/Ns*1/OVR*abs(fft(W2.*tone_con, NFFT));
dac_response = abs(fft(dac_filter,NFFT));

figure
subplot 311
plot(fvec_td(1:NFFT/2), spect_disc(1:NFFT/2),'-b','LineWidth',2.5);
hold all
grid on
xlabel('Frequency [Hz]');
ylabel('Amplitude [V]');
legend('Discrete sequence spectrum');
title('[Act. 1] Analisis espectral tono discreto');

subplot 312
plot(fvec_tc(1:NFFT/2), spect_x_up(1:NFFT/2),'-b','LineWidth',3);
hold all
plot(fvec_tc(1:NFFT/2), dac_response(1:NFFT/2)/dac_response(1),'--k','LineWidth',2);
grid on
xlabel('Frequency [Hz]');
ylabel('Amplitude [V]');
legend('Upsampled discrete sequence', 'DAC Filter response');
title('[Act. 1] Analisis espectral tono discreto upsample vs filtro reconstrucción');

subplot 313
plot(fvec_tc(1:NFFT/2), spect_tc(1:NFFT/2),'-b','LineWidth',3);
hold all
plot(fvec_tc(1:NFFT/2), spect_tone_con(1:NFFT/2),'--k','LineWidth',2)
grid on
xlabel('Frequency [Hz]');
ylabel('Amplitude [V]');
legend('Cont. time signal','Cont. Ref. time signal' );
title('[Act. 1] Analisis espectral tono reconstruido Vs, tono continuo');
