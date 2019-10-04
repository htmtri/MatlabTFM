function removeLinesEOF(fname,remv)
if ~(remv == 0)
    fid = fopen(fname,'rb');
    str = textscan(fid,'%s','Delimiter','\n');
    fseek(fid, 0, 'eof');
    fileSize = ftell(fid);
    frewind(fid);
    data = fread(fid, fileSize, 'uint8');
    numLines = sum(data == 10) + 1;
    str2 = str{1}(1:(numLines-remv));
    fid2 = fopen(fname,'w');
    fprintf(fid2,'%s\n', str2{1:end-1});
    fprintf(fid2,'%s', str2{end});
    fclose(fid2);
    fclose(fid);
end
end