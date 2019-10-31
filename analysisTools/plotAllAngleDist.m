close all; clearvars;
cwd = pwd;
selpath = uigetdir;
cd(selpath)
mat = dir('*.mat');

for k=1:length(mat)
    m = matfile(mat(k).name,'Writable',true);
    
    udist = m.uniquedist.*0.161;
    
    g = fittype('a+b*exp(-c*x)');
    % options = fitoptions('exp1','Normalize', 'on','Algorithm','Levenberg-Marquardt')
    f = fit(udist,m.avgangle,g,'Exclude',udist > 20);
    % plot(f,udist(idf),avgangle(idf))
    
    figure(k)
    hold on
    plot(f,udist,m.avgangle,'.')
    xlabel('Distance[\mum]')
    ylabel('<cos \theta> of two stress vectors')
%     xlim([0 100])
    ylim([0 1])
    saveas(gcf,['AngleDist',mat(k).name(1:end-4),'.png'])
    m.fitmodel = f;
    m.b = f.b;
    m.c = f.c;
end
hold off