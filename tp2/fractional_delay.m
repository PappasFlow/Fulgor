function [x_out, h1] = fractional_delay(x_in, frac_delay, n_taps)
    group_delay = (n_taps-1)/2; % Este delay hay que compensarlo porque representa la cola de la convolucion
    nline = (-(n_taps-1)/2:(n_taps-1)/2);
    h1 = sinc(nline-frac_delay);
    x_in_tran = transpose(x_in);
    x_out = filter(h1,1,[x_in_tran; zeros(group_delay,1)]); % Agrego zeros para mantener el largo de la senial filtrada
    x_out = x_out(group_delay+1:end); % Corrijo el retardo de grupo
    x_out = transpose(x_out);
end