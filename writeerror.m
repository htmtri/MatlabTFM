function writeerror(sname,message)
fname = ['#Error',sname];

if ~exist([fname,'.txt'],'file')
    fileID=fopen(fname,'w');
else
    fileID=fopen(fname,'r');
end
fprintf(fileID,message);
fclose(fileID);

end