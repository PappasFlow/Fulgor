clear; close all;

%% Output directory

out_dir = mfilename('fullpath');
out_dir = out_dir(1:end-length(mfilename));
out_dir = [out_dir, 'out/'];

if ~exist(out_dir,'dir')
    mkdir(out_dir);
end

%% Set Default Settings
default_settings;

%% Sweep Parameters

M_v = [4 16];
n_M = length(M_v);

%Increase the default Lsymbs to obtain a meaningful BER calculation
config_s.tx_s.Lsymbs = 1e7; 

ber_max = 5e-2;
ber_min = 1e-6;
n_ber = 10;
linespace_v = linspace(log10(ber_min), log10(ber_max), n_ber);
theo_ber_v = 10.^(linespace_v);

% Save configuration
file = [out_dir, 'cfg.mat'];
save(file, 'M_v','theo_ber_v','config_s');

out_c = cell(n_M, 1); 

%% Instantiation

for i_M = 1:n_M
    
    M = M_v(i_M);
    ebno_db_v = get_ebno_from_theo_ber(theo_ber_v,M);
    config_s.tx_s.M = M;
    
    % Enable parallel pool for faster processing
    % Rule of thumb for number of workers: Cores - 1
    parfor i_ber = 1:n_ber
        config_s_p = config_s;
        config_s_p.ch_s.ebno_db = ebno_db_v(i_ber);
    
        fprintf('- Running M=%d(%d/%d) ...\n', M,i_ber,n_ber)

        out_c{i_ber} = m_simulator(config_s_p);q
    end
    
    name = sprintf('M%d',M);
    file = [out_dir, 'out_',name,'.mat'];
    save(file, 'out_c');
    
end
