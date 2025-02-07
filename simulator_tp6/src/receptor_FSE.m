function [o_data_s] = receptor_FSE(i_rx_s, i_config_s)
    
    %--------------------------%
    %     DEFAULT SETTINGS
    %--------------------------%
    
    config.M = 16;
    config.NOS = 2;
    config.BR = 32e9;
    config.plot=0;
    config.step=2e-3;
    config.dwn_phase = 0;
    
    %--------------------------%
    %       REASSIGNMENT
    %--------------------------%
    
    fn = fieldnames(i_config_s);
    for k = 1:numel(fn)
        if isfield(config,(fn{k}))==1
            config.(fn{k})= i_config_s.(fn{k});
        else
            error('%s: Parametro del simulador no valido', fn{k})
        end
    end
    
    %--------------------------%
    %         VARIABLES
    %--------------------------%
    
    rx = i_rx_s.signal_v;
    
    N = config.NOS;
    BR = config.BR;
    
    g = i_rx_s.htx_v;
    b = i_rx_s.hch_v;
    
    
    %--------------------------%
    %   AUTOMATIC GAIN CONTROL (AGC)
    %--------------------------%
    agc_gain = 1 / std(rx); % Normalizar amplitud de la señal
    rx = rx * agc_gain;
    
    %--------------------------%
    %         PROCESS
    %--------------------------%
%%
    NTAPS=101;
    step = config.step;
    leak = 1e-3;
    Xbuffer = zeros(NTAPS,1);
    W = zeros(1, NTAPS);
    W((NTAPS+1)/2)=1.0;
    LY = length(rx);
    out_eq = zeros(LY,1);
    out_eq_down = zeros(LY/2,1);

    % Plot
   % figure(100);
    NFFT=256;
    f = N*(-BR/2:BR/NFFT:BR/2-BR/NFFT);
    %plot(f/1e9,20.*log10(abs(fftshift(fft(conv(g,b), NFFT)))),'LineWidth',2)
    %hold on;

    for m=1:LY-NTAPS-1

        Xbuffer(2:end) = Xbuffer(1:end-1); Xbuffer(1)=rx(m);
        yeq = W * Xbuffer;
        out_eq(m)=yeq;

        if mod(m,N)==0

            err = yeq - my_slicer(yeq, config.M);
            grad = err.*Xbuffer';
            W = W*(1-step*leak) - step*grad;
            out_eq_down(m/N)=yeq;

        end


    end

%%
    
    % Slicer
    ak_hat_v = my_slicer(out_eq_down, config.M);
    
    %--------------------------%
    %         OUTPUT
    %--------------------------%
    
    o_data_s.ak_hat_v = ak_hat_v;
    o_data_s.y_up_v = out_eq;
    o_data_s.y_v = out_eq_down;
   
   %% plots puntos 1 2 3
    if config.plot
         figure(100); clf;
         HCH = abs(fftshift(fft(conv(g,b), NFFT)));
         plot(f/1e9,20.*log10(HCH),'r','LineWidth',2) %solo ch
         hold on; grid on;
         HEQ = abs(fftshift(fft(W, NFFT)));
         plot(f/1e9,20.*log10(HEQ/(max(HEQ))),'LineWidth',2) %solo eq
         plot(f/1e9,20.*log10(abs(HCH.*HEQ/(max(HEQ)))),'g','LineWidth',1.5)%convolucion ch eq
         plot([BR BR]/2/1E9,ylim,'-.m','LineWidth',2)
         plot(-[BR BR]/2/1E9,ylim,'-.m','LineWidth',2)
         
         title('Respuestas en frecuencia')
         legend({'Channel','Equalizer','Covolucion CH EC','+/- BR/2'},'Location','s')
         xlabel('Frequency [GHz]')
         ylabel('Amplitude [dB]')


        figure
        subplot 211
        stem(real(W), 'LineWidth', 2);
        xlim([0 length(W)]);
        grid on
        xlabel('Tap Number')
        ylabel('Tap Amplitude')
        title('Impulse Response of equalizer (real)')
        hold all
        subplot 212
        stem(imag(W),'r'); % El canal es real, la parte imaginaria es siempre 0
        xlim([0 length(W)]);
        grid on
        xlabel('Tap Number')
        ylabel('Tap Amplitude')
        title('Impulse Response of equalizer (imaginario)')
    end

end

