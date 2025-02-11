clear; close all;

%% Output directory

out_dir = mfilename('fullpath');
out_dir = out_dir(1:end-length(mfilename));
out_dir = [out_dir, 'out/'];

if ~exist(out_dir,'dir')
    mkdir(out_dir);
end

    %--------------------------%
    %     DEFAULT SETTINGS
    %--------------------------%

    % -- General --
    config_s.en_plots = 0;

    % -- Tx --
    config_s.tx_s.Lsymbs = 1e6;                 % Cantidad de simbolos
    
    config_s.tx_s.BR = 32e9;                    % Baud rate
    config_s.tx_s.M = 4;                       % Niveles de la modulacion
    
    config_s.tx_s.NOS = 2;                      % Tasa de sobremuestreo
    
    config_s.tx_s.rolloff = 0.5;                % Rolloff del filtro conformador
    config_s.tx_s.pulse_shaping_ntaps = 201;     % Cantidad de taps del PS
    config_s.tx_s.pulse_shaping_type = 0;       % 0: RRC, 1: RC
    
    % -- Ch --
    config_s.ch_s.mode = 0;                     %filtrado antes(0) o despues(1) del ruido
    config_s.ch_s.en_noise = 1;                 % 0:OFF ; 1:ON
    config_s.ch_s.ebno_db = 4;                  % EbNo [dB]
    
    config_s.ch_s.en_bw_lim = 1;                % 0:OFF ; 1:ON
    config_s.ch_s.bw_order = 24;                % BW order
    config_s.ch_s.bw = 20e9;                    % BW lim [Hz]
    
    % -- Rx -- 
    config_s.rx_s.step=2e-3;                   %step size eq
    config_s.rx_s.plot=1;                      %plots on off
    config_s.rx_s.dwn_phase = 0;               % Downsampling phase
    config_s.rx_s.ntaps = 101;

%% Local Configuration
config_s.rx_s.plot=0;
% BW limit after noise
config_s.ch_s.mode = 1;
M = 4;
config_s.tx_s.M = M;
%Increase the default Lsymbs to obtain a meaningful BER calculation
config_s.tx_s.Lsymbs = 1e6; 

%% Sweep Parameters
stpsz_v = [1e-4 5e-4 1e-3 2e-3];
n_stpsz = length(stpsz_v);

ber_max = 5e-2;
ber_min = 1e-6;
n_ber = 6;
linespace_v = linspace(log10(ber_min), log10(ber_max), n_ber);
theo_ber_v = 10.^(linespace_v);

% Save configuration
file = [out_dir, 'cfg.mat'];
save(file, 'stpsz_v','theo_ber_v','config_s');

out_c = cell(n_stpsz, 1); 

%% Instantiation
for i_stpsz = 1:n_stpsz
    
    stpsz = stpsz_v(i_stpsz);
    ebno_db_v = get_ebno_from_theo_ber(theo_ber_v,M);
    config_s.rx_s.step = stpsz;

        % Enable parallel pool for faster processing
        % Rule of thumb for number of workers: Cores - 1    
    parfor i_ber = 1:n_ber
        config_s_p = config_s;
        config_s_p.ch_s.ebno_db = ebno_db_v(i_ber);
    
        fprintf('- Running STEP=%.1fHz(%d/%d) ...\n',stpsz*1e3 ,i_ber,n_ber)

        out_c{i_ber} = m_simulator(config_s_p);
    end
    
    name = sprintf('STEP%.1f',stpsz*1e3);
    file = [out_dir, 'out_',name,'.mat'];
    save(file, 'out_c');
    
end