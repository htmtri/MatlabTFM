function out=TFM_Note()
afile = dir('*.mat');
for i = 1:length(afile)
   samp(i).name = afile(i).name(1:end-4); 
end

%% PRNSOL
for i = [1:length(afile)]
    disp('Count those lines not for nodal displacements at the end of ANSYS solution file PRNSOL**.txt')
    system(['NOTEPAD.exe PRNSOL_',samp(i).name,'.txt'])
    
    remv=input('Number of lines to remove(19 or 36): ');
    if isempty(remv)
        remv=36 %values are usually 36 or 19)
    end
    
    fid = fopen(['PRNSOL_',samp(i).name,'.txt'],'rb');
    str = textscan(fid,'%s','Delimiter','\n');
    fseek(fid, 0, 'eof');
    fileSize = ftell(fid);
    frewind(fid);
    data = fread(fid, fileSize, 'uint8');
    numLines = sum(data == 10) + 1;
    str2 = str{1}(1:(numLines-remv));
    fid2 = fopen(['PRNSOL_',samp(i).name,'.txt'],'w');
    fprintf(fid2,'%s\n', str2{1:end-1});
    fprintf(fid2,'%s', str2{end});
    fclose(fid2);
    fclose(fid);
end
%% PRNLD
for i = [1:length(afile)]
disp('Count those lines not for nodal displacements at the end of ANSYS solution file PRNLD**.txt')
system(['NOTEPAD.exe PRNLD_',samp(i).name,'.txt'])

remv=input('Number of lines to remove(4 or 21): ');
if isempty(remv)
    remv=4 %values are usually 4 or 21)
end
    
    fid = fopen(['PRNLD_',samp(i).name,'.txt'],'rb');
    str = textscan(fid,'%s','Delimiter','\n');
    fseek(fid, 0, 'eof');
    fileSize = ftell(fid);
    frewind(fid);
    data = fread(fid, fileSize, 'uint8');
    numLines = sum(data == 10) + 1;
    str2 = str{1}(1:(numLines-remv));
    fid2 = fopen(['PRNLD_',samp(i).name,'.txt'],'w');
    fprintf(fid2,'%s\n', str2{1:end-1});
    fprintf(fid2,'%s', str2{end});
    fclose(fid2);
    fclose(fid);
end
%% PRNSOL_U
for i = [1:length(afile)]
disp('Count those lines not for nodal displacements at the end of ANSYS solution file PRNSOL_U**.txt')
system(['NOTEPAD.exe PRNSOL_U',samp(i).name,'.txt'])

remv=input('Number of lines to remove(5 or 22): ');
if isempty(remv)
    remv=5 %values are usually 5 or 22)
end
    
    fid = fopen(['PRNSOL_U',samp(i).name,'.txt'],'rb');
    str = textscan(fid,'%s','Delimiter','\n');
    fseek(fid, 0, 'eof');
    fileSize = ftell(fid);
    frewind(fid);
    data = fread(fid, fileSize, 'uint8');
    numLines = sum(data == 10) + 1;
    str2 = str{1}(1:(numLines-remv));
    fid2 = fopen(['PRNSOL_U',samp(i).name,'.txt'],'w');
    fprintf(fid2,'%s\n', str2{1:end-1});
    fprintf(fid2,'%s', str2{end});
    fclose(fid2);
    fclose(fid);
end
end