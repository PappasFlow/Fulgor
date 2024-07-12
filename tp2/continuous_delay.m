function [x_out] = continuous_delay(x_in, sample_delay)
    x_out = [zeros(1, sample_delay), x_in(1:end-sample_delay)];
end