function [o_data_s] = receptor_MQAM(i_rx_s, i_config_s)
    
    %--------------------------%
    %     DEFAULT SETTINGS
    %--------------------------%
    
    config.M = 16;
    config.NOS = 2;
    config.BR = 32e9;
    
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
    
    hch_v = i_rx_s.hch_v;
    htx_v = i_rx_s.htx_v;
    h_tot_v = filter(hch_v, 1, htx_v);
    
    h_mf_v = conj(h_tot_v(end:-1:1));
    
    %--------------------------%
    %         PROCESS
    %--------------------------%
    
    % Filtrado con matched filter
    y_up_v = filter(h_mf_v, 1, i_rx_s.signal_v);
    
    % Downsampling
    y_v = y_up_v(1+config.dwn_phase:config.NOS:end);
    
    % Slicer
    ak_hat_v = my_slicer(y_v, config.M);
    
    %--------------------------%
    %         OUTPUT
    %--------------------------%
    
    o_data_s.ak_hat_v = ak_hat_v;
    o_data_s.y_up_v = y_up_v;
    o_data_s.y_v = y_v;
        
end

