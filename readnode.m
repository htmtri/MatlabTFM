function nodev=readnode(filn,nshead,hdhils,nodesz,cols)
%% Read data from ANSYS output files. 
% The ANSYS output file are well organized. It has a few lines at the
% begining of the file to desribe the contents in the file. 
% data are organized into sections, with descriptions in each section.
% *** Note:  Before using this routine to read data, please open the file
% with any text editor and delete nondata lines at the end of the file.
%**** Parameters: 
% filn is the file name 
% nshead is number of lines before the pattern
% hdhils is the number of lines before the data sections
% nodesz is the number of data lines per section
% cols is the number of colunmns in the data
%% Qi Wen Feb/2012
%% Minh Sep 2019 - randomly generate name for parallel workers
tempf = randseq(12);
copyfile(filn,tempf);
a=fopen(tempf,'r');
block=1;
ad=[];
Inputtext=textscan(a,'%s',nshead,'delimiter','\n');
while (~feof(a))
    sprintf('Block, %s',num2str(block));
    Inputtext=textscan(a,'%s',hdhils,'delimiter','\n');
    fmt='\t %f';
    for i=1:cols-1
        fmt=[fmt,' \t %f'];
    end
    datput=textscan(a,fmt,nodesz,'delimiter','\n');
    datab{block,1}= cell2mat(datput);
    ad=[ad;datab{block,1}];
    block=block+1;
end
fclose(a);
delete(tempf)
nodev.datab=datab;
nodev.nodes=ad;
    