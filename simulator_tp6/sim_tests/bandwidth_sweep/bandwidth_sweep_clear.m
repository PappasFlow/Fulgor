curr_dir = mfilename('fullpath');
curr_dir = curr_dir(1:end-length(mfilename));
out_dir = [curr_dir, 'out/'];
if exist(out_dir,'dir')
    rmdir(out_dir, 's')
end

