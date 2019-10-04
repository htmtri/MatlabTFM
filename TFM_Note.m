function TFM_Note()
afile = dir('*.mat');
for i = 1:length(afile)
   samp(i).name = afile(i).name(1:end-4); 
end

automode=input('Do you want programe to autocrop textfile? 1[yes] 0[no]')

if ~(automode == 1 || automode == 0)
    warning('wrong input for auto. Default to 0[manual]')
    automode = 0;
end

if automode == 1
    for i = 1:length(afile)
        cropANSYSoutput(['PRNSOL_',samp(i).name,'.txt'])
        cropANSYSoutput(['PRNLD_',samp(i).name,'.txt'])
        cropANSYSoutput(['PRNSOL_U',samp(i).name,'.txt'])
    end
    
else

for i = 1:length(afile)
    disp('Count those lines not for nodal displacements at the end of ANSYS solution file PRNSOL**.txt')
    system(['NOTEPAD.exe PRNSOL_',samp(i).name,'.txt'])
    
    remv1=input('Number of lines to remove(19 or 36): ');
    if isempty(remv1)
        warning('no input. Default to 0')
        remv1=0 %values are usually 36 or 19)
    end
    
    removeLinesEOF(['PRNSOL_',samp(i).name,'.txt'],remv1)
    
    disp('Count those lines not for nodal displacements at the end of ANSYS solution file PRNLD**.txt')
    system(['NOTEPAD.exe PRNLD_',samp(i).name,'.txt'])
    
    remv2=input('Number of lines to remove(4 or 21): ');
    if isempty(remv2)
        warning('no input. Default to 0')
        remv2=0 %values are usually 4 or 21)
    end
    
    removeLinesEOF(['PRNLD_',samp(i).name,'.txt'],remv2)
    
    disp('Count those lines not for nodal displacements at the end of ANSYS solution file PRNSOL_U**.txt')
    system(['NOTEPAD.exe PRNSOL_U',samp(i).name,'.txt'])
    
    remv3=input('Number of lines to remove(5 or 22): ');
    if isempty(remv3)
        warning('no input. Default to 0')
        remv3=0 %values are usually 5 or 22)
    end
    
    removeLinesEOF(['PRNSOL_U',samp(i).name,'.txt'],remv3)
    
end
end
end