function cropANSYSoutput(fname)

fid = fopen(fname,'rb');
str = textscan(fid,'%s','Delimiter','\n');

fseek(fid, 0, 'eof');
fileSize = ftell(fid);
frewind(fid);
data = fread(fid, fileSize, 'uint8');
numLines = sum(data == 10) + 1;
remv = 0;

for i = numLines-1:-1:1
    subst = strsplit(str{1}{i});
    if ~isempty(subst{1})
        if length(subst{1})>1 && ~startsWith(subst{1},'00') && ~isnan(str2double(subst{1}))
            remv = numLines - 1 - i;
            break
        end
    end
end

if ~(remv == 0)
str2 = str{1}(1:(numLines-remv-1));
fid2 = fopen(fname,'w');
fprintf(fid2,'%s\n', str2{1:end-1});
fprintf(fid2,'%s', str2{end});
fclose(fid2);
fclose(fid);
end
end