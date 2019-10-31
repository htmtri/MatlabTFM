function plotAngleDist(samp,varargin)

if nargin == 0
    disp('Not enough input arguments, need .mat file')
elseif nargin == 1
    uthres = 20;
elseif nargin == 2
    uthres = varargin{1};
else
    disp('Too many inputs')
    return;
end

    m = matfile([samp,'.mat'],'Writable',true);
    
    udist = m.uniquedist.*0.161;
    
%     idf = udist < 50;
    g = fittype('a+b*exp(-c*x)');
    % options = fitoptions('exp1','Normalize', 'on','Algorithm','Levenberg-Marquardt')
    f = fit(udist,m.avgangle,g,'Exclude',udist > uthres);
    % plot(f,udist(idf),avgangle(idf))
    
    figure()
    hold on
    plot(f,udist,m.avgangle,'.')
    xlabel('Distance[\mum]')
    ylabel('<cos \theta> of two stress vectors')
    ylim([0 1])
    saveas(gcf,['AngleDist',samp,'.png'])
    m.fitmodel = f;
    m.b = f.b;
    m.c = f.c;
end