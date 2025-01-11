function [o_data_s] = canal_MQAM(i_ch_s, i_config_s)
    
    %--------------------------%
    %     DEFAULT SETTINGS
    %--------------------------%
    
    config.BR = 32e9;         % Cantidad de niveles de la modulacion
    config.M = 16;            % Orden de modulacion
    config.NOS = 2;           % Factor de sobremuesteo
    
    config.en_noise = 1;      % 0:OFF ; 1:ON
    config.ebno_db = 6;       % Eb/No en dB
    
    config.en_bw_lim = 0;     % 0:OFF ; 1:ON
    config.bw_order = 6;      % BW order
    config.bw = 10e9;         % BW lim [Hz]
    
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
    
    en_bw_lim = config.en_bw_lim;       % 0: Impulso, 1: FIR generico
    ebno_db = config.ebno_db;           % Eb/No en dB
    M = config.M;                       % Orden de modulacion
    NOS = config.NOS;                   % Factor de sobremuesteo
    s_v = i_ch_s.signal_v;              % Señal de entrada
    
    % Filtro
    if en_bw_lim
        fs = config.NOS*config.BR;
        fc = config.bw/(fs/2);
        h_v = fir1(config.bw_order, fc);  
    else
        h_v = 1;
    end
    
    % Generación de ruido
    k = log2(M);
    EbNo_veces = 10^(ebno_db/10);
    SNR_slc = k*EbNo_veces;
    SNR_ch = SNR_slc/NOS;
    Ps = var(s_v);   
    Pn = Ps / SNR_ch;
    
    %--------------------------%
    %         PROCESS
    %--------------------------%
    
    % Ruido
    if config.en_noise
        n_v = sqrt(Pn/2).*(randn(size(s_v)) + 1j.*randn(size(s_v)));
    else
        n_v = 0;
    end
    
    % Filtrado
    r_v = s_v + n_v;
    r_v = filter(h_v, 1, r_v);
    
    %--------------------------%
    %         OUTPUT
    %--------------------------%
    
    o_data_s.signal_v = r_v;
    o_data_s.hch_v = h_v;
    
end