% getWAMITRAO
% Written by Salman Husain
% Edited by Courtney Beringer
% August 2023

clc;clear;close all

mode = 3;

fname = 'float';

%%

n_angle = 1;
n_body = 1; %number of bodies
modes_tmp = [1 2 3 4 5 6];
modes = [];
for i = 1:n_body
modes = [modes modes_tmp];
end

fileID = fopen([fname '.4']);
rao_out = textscan(fileID,'%f %f %f %f %f %f %f %f','HeaderLines',1);
fclose(fileID);
rao.data = cell2mat(rao_out);
n_modes = find(and(rao.data(2:end,3)==rao.data(1,3), ...
rao.data(2:end,4)==rao.data(1,4)),1);

%% Package it all up

rao.w = 2*pi./rao.data(mode:length(modes):end,1);
rao.mod = rao.data(mode:length(modes):end,4);
rao.phase = rao.data(mode:length(modes):end,5);

close all
clearvars -except rao

%%
figure()
plot(rao.w,rao.mod,'-r','LineWidth',2)
grid on
legend('RAO Magnitude','Location','best')
figure()
plot(rao.w,rao.phase,'-b','LineWidth',2)
grid on
hold on
legend('RAO Phase','Location','best')

%% Save data
save('RAO_float')