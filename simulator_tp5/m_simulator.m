%-----------------------------------------------------------------------------%
%                                   FULGOR
%
% Programmer(s): Francisco G. Rainero 
% Created on   : 2023
% Description  : QAM simulator
%-----------------------------------------------------------------------------%

function o_data_s = m_simulator(i_cfg_s)

    %--------------------------%
    %     DEFAULT SETTINGS
    %--------------------------%

    % -- General --
    config_s.en_plots = 1;

    % -- Tx --
    config_s.tx_s.Lsymbs = 1e6;                 % Cantidad de simbolos
    
    config_s.tx_s.BR = 32e9;                    % Baud rate
    config_s.tx_s.M = 4;                       % Niveles de la modulacion
    
    config_s.tx_s.NOS = 2;                      % Tasa de sobremuestreo
    
    config_s.tx_s.rolloff = 0.5;                % Rolloff del filtro conformador
    config_s.tx_s.pulse_shaping_ntaps = 24;     % Cantidad de taps del PS
    config_s.tx_s.pulse_shaping_type = 0;       % 0: RRC, 1: RC
    
    % -- Ch --
    config_s.ch_s.en_noise = 1;                 % 0:OFF ; 1:ON
    config_s.ch_s.ebno_db = 8;                  % EbNo [dB]
    
    config_s.ch_s.en_bw_lim = 1;                % 0:OFF ; 1:ON
    config_s.ch_s.bw_order = 24;                % BW order
    config_s.ch_s.bw = 20e9;                    % BW lim [Hz]
    
    % -- Rx -- 
    config_s.rx_s.dwn_phase = 0;                % Downsampling phase
    
    %--------------------------%
    %       REASSIGNMENT
    %--------------------------%

    if nargin > 0
        config_s = overwrite_parameters(i_cfg_s, config_s);
    end

    % Shared variables
    config_s.ch_s.M = config_s.tx_s.M;
    config_s.rx_s.M = config_s.tx_s.M;
    config_s.ch_s.BR = config_s.tx_s.BR;
    config_s.rx_s.BR = config_s.tx_s.BR;
    config_s.ch_s.NOS = config_s.tx_s.NOS;
    config_s.rx_s.NOS = config_s.tx_s.NOS;
    
    %--------------------------%
    %          PROCESS
    %--------------------------%

    % -- Tx --
    o_tx_s = transmisor_MQAM(config_s.tx_s);

    % -- Ch --
    i_ch_s.signal_v = o_tx_s.signal_v;
    o_ch_s = canal_MQAM(i_ch_s, config_s.ch_s);
    
    % -- Rx --
    i_rx_s.htx_v = o_tx_s.htx_v;
    i_rx_s.hch_v = o_ch_s.hch_v;
    i_rx_s.signal_v = o_ch_s.signal_v;
    o_rx_s = receptor_MQAM(i_rx_s, config_s.rx_s);
    
    % -- BER checker --
    ak_v = o_tx_s.ak_v;
    ak_hat_v = o_rx_s.ak_hat_v;
    [ber_est, n_errors] = ...
                    my_ber_checker(ak_hat_v,ak_v,config_s.tx_s.M,'auto');
    
    if n_errors<100
        warning('BER estimation may be not accurate');
    end
                
    % Theo
    ber_theo = berawgn(config_s.ch_s.ebno_db, 'QAM', config_s.tx_s.M);

    %--------------------------%
    %          PLOTS
    %--------------------------%

    if config_s.en_plots 
        
        % Diagrama de ojo a la salida del transmisor
        eyediagram(o_tx_s.signal_v(5e3:20e3), config_s.tx_s.NOS);
        grid on;
        title('a) Tx\_data');
        set(gcf, 'Position', [50 50 600 600],'Color', 'w');
        
        % PSD a la salida del tx superpuesta con la PSD a la entrada del mf
        NFFT = 1024*8;
        window_v = hanning(NFFT/2); % Largo del bloque de NFFT/2 muestras
        fs=config_s.tx_s.BR*config_s.tx_s.NOS;
        [s_tx, f_tx] = pwelch(o_tx_s.signal_v, window_v, 0, NFFT, fs);
        [s_rv, f_rv] = pwelch(o_ch_s.signal_v, window_v, 0, NFFT, fs);
        
        figure;
        plot(f_tx/1e9, 10*log10(s_tx) );
        grid on;
        hold all;
        plot(f_rv/1e9, 10*log10(s_rv), '--k', 'LineWidth', 2);
        title('b) PSD Tx y PSD antes de MF','Interpreter','latex','FontSize', 15);
        xlabel('Frecuencia discreta [GHz]');
        ylabel('Amplitud [dB]');
        legend('Salida Tx', 'Entrada Rx');
        set(gcf, 'Position', [50 50 600 600],'Color', 'w');
        
        % PSD a la entrada del mf superpuesta con la PSD luego del mf
        %[s_rx, f_rx] = pwelch(o_rx_s.y_v, window_v, 0, NFFT, fs);
        [s_rx, f_rx] = pwelch(o_rx_s.y_up_v, window_v, 0, NFFT, fs); 
        figure;
        plot(f_rx/1e9, 10*log10(s_rx) );
        grid on;
        hold all;
        plot(f_rv/1e9, 10*log10(s_rv), '--k', 'LineWidth', 2);
        title('c) PSD antes y luego del MF','Interpreter','latex','FontSize', 15);
        xlabel('Frecuencia discreta [GHz]');
        ylabel('Amplitud [dB]');
        legend('Salida MF', 'Entrada Rx');
        set(gcf, 'Position', [50 50 600 600],'Color', 'w');
        
        
         % PSD a la entrada del mf superpuesta con la PSD luego de downsampler
        [s_rx, f_rx] = pwelch(o_rx_s.y_v, window_v, 0, NFFT, fs); 
        figure;
        plot(f_rx/1e9, 10*log10(s_rx) );
        grid on;
        hold all;
        plot(f_rv/1e9, 10*log10(s_rv), '--k', 'LineWidth', 2);
        title('extra) PSD antes y luego de decimar','Interpreter','latex','FontSize', 15);
        xlabel('Frecuencia discreta [GHz]');
        ylabel('Amplitud [dB]');
        legend('Salida Rx', 'Entrada Rx');
        set(gcf, 'Position', [50 50 600 600],'Color', 'w');

        % Constelacion a la entrada del slicer
        scatterplot(o_rx_s.y_v);
        grid on;
        title('d) Constelación entrada del slicer');
        set(gcf, 'Position', [50 50 600 600],'Color', 'w');
        
        % Constelacion a la salida del slicer
        scatterplot(o_rx_s.ak_hat_v);
        grid on;
        title('extra) Constelación salida del slicer');
        set(gcf, 'Position', [50 50 600 600],'Color', 'w');
        
        figure
        subplot(2, 1, 1);
        hist(real(o_rx_s.y_v), 500);  % 100 es el número de bins
        title('Histograma - parte real entrada del slicer');
        grid on;
        subplot(2, 1, 2);
        hist(imag(o_rx_s.y_v), 500);
        title('Histograma - parte imaginaria entrada del slicer');
        grid on;
        set(gcf, 'Position', [50 50 600 600], 'Color', 'w');

    end

    %--------------------------%
    %          OUTPUT
    %--------------------------%

    o_data_s.ber_est = ber_est;
    o_data_s.ber_theo = ber_theo;

end
