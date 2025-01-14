clear; close all;

%% Output directory

out_dir = mfilename('fullpath');
out_dir = out_dir(1:end-length(mfilename));
out_dir = [out_dir, 'out/'];

if ~exist(out_dir,'dir')
    mkdir(out_dir);
end

%% General configuration

% -- General --
config_s.en_plots = 0;

% -- Tx --
config_s.tx_s.Lsymbs = 1e6;                 % Cantidad de simbolos

config_s.tx_s.BR = 32e9;                    % Baud rate
config_s.tx_s.M = 16;                       % Niveles de la modulacion

config_s.tx_s.NOS = 2;                      % Tasa de sobremuestreo

config_s.tx_s.rolloff = 0.5;                % Rolloff del filtro conformador
config_s.tx_s.pulse_shaping_ntaps = 61;     % Cantidad de taps del PS
config_s.tx_s.pulse_shaping_type = 0;       % 0: RRC, 1: RC

% -- Ch --
config_s.ch_s.en_noise = 1;                 % 0:OFF ; 1:ON
config_s.ch_s.ebno_db = 8;                  % EbNo [dB]

config_s.ch_s.en_bw_lim = 1;                % 0:OFF ; 1:ON
config_s.ch_s.bw_order = 18;                % BW order
config_s.ch_s.bw = 20e9;                    % BW lim [Hz]

% -- Rx -- 
config_s.rx_s.dwn_phase = 0;                % Downsampling phase

%% Testing Parameters

config_s.en_plots = 1;

%% Instantiation

out_c = m_simulator(config_s)

FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for idx_fig = 1:length(FigList)
  FigHandle = FigList(idx_fig);
  saveas(FigHandle,[out_dir,sprintf('fig%d.png',length(FigList)+1-idx_fig)]);
end
