function parsavestruct(fname,field)
%% To be used for saving a struct file inside a parfor loop
save(fname, '-struct', 'field')
end