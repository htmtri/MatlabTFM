function outp=TFMTL_Data3(samp)

init = 1;
fin = 28;

if exist([samp,'.mat'],'file')
    load([samp,'.mat']);
    
%% Plot TF vs time

figure(1)
scatter(time(init:fin),totalForce(init:fin)*10^9,'b.')
ylabel('Total Force [nN]')
xlabel('Time [min]')


%% Plot MaxStress vs Time
figure(2)
scatter(time(init:fin),MaxStress(init:fin),'r.')
ylabel('Maximum Stress [Pa]')
xlabel('Time [min]')

%% Plot Strain Energy vs Time
% figure(3)
% scatter(time(1:49),StrainEnergy(1:49)*10^12,'k.')
% ylabel('Strain Energy [pJ]')
% xlabel('Time [min]')

%% Plot Cell Area vs Time
figure(4)
scatter(time(init:fin),Area*0.161*0.161*0.8,'k*')
ylabel('Cell Area [um2]')
xlabel('Time [min]')

%% Plot Aspect Ratio vs Time
figure(5)
scatter(time(init:fin),AspectRatio,'ko')
ylabel('Aspect Ratio')
xlabel('Time [min]')

%% Plot Roundness vs Time
% figure(6)
% scatter(time(1:49),Roundness,'b.')
% ylabel('Roundness')
% xlabel('Time [min]')

%% Plot Solidity vs Time
% figure(7)
% scatter(time(1:49),Solidity,'b.')
% ylabel('Solidity')
% xlabel('Time [min]')

%% Plot Displacement vs Time
figure(8)
scatter(time(init:fin),Displacement*0.161,'m.')
ylabel('Displacement [um]')
xlabel('Time [min]')

%% Plot Speed vs Time
% figure(9)
% scatter(time,Speed,'b.')
% ylabel('Speed [um/min]')
% xlabel('Time [min]')
else
    return
end
