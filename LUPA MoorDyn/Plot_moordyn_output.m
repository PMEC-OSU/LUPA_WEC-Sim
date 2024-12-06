% Read the data from the .out file
data = dlmread('Mooring/lines_Body1.out', '', 2, 0); % Replace 'data.out' with the name of your file

% Extract the columns
time = data(:, 1);
x = data(:, 2);
y = data(:, 3);
z = data(:, 4);
roll = data(:, 5);
pitch = data(:, 6);
yaw = data(:, 7);

% Plot x vs time
figure;
subplot(3,2,1);
plot(time, x);
xlabel('Time (s)');
ylabel('x');
title('x vs Time');

% Plot y vs time
subplot(3,2,2);
plot(time, y);
xlabel('Time (s)');
ylabel('y');
title('y vs Time');

% Plot z vs time
subplot(3,2,3);
plot(time, z);
xlabel('Time (s)');
ylabel('z');
title('z vs Time');

% Plot roll vs time
subplot(3,2,4);
plot(time, roll);
xlabel('Time (s)');
ylabel('Roll');
title('Roll vs Time');

% Plot pitch vs time
subplot(3,2,5);
plot(time, pitch);
xlabel('Time (s)');
ylabel('Pitch');
title('Pitch vs Time');

% Plot yaw vs time
subplot(3,2,6);
plot(time, yaw);
xlabel('Time (s)');
ylabel('Yaw');
title('Yaw vs Time');

% Adjust layout
sgtitle('Quantities vs Time');

%% plots the Line1,2,3 output files
data1 = dlmread('Mooring/lines_Line1.out', '', 1, 0); % Replace 'data.out' with the name of your file

time = data1(:, 1);
Node0px = data1(:, 2);
Node0py = data1(:, 3);
Node0pz = data1(:, 4);
Node15px = data1(:, 17);
Node15py = data1(:, 18);
Node15pz = data1(:, 19);
% Seg1Te = data1(:, 50);
% Seg2Te = data1(:, 51);
% Seg14Te = data1(:, 63);
% Seg15Te = data1(:, 64);

figure;
subplot(3,2,1);
plot(time, Node0px);
xlabel('Time (s)');
ylabel('Node0px');
title('Node0px vs Time');

% Plot y vs time
subplot(3,2,2);
plot(time, Node0py);
xlabel('Time (s)');
ylabel('Node0py');
title('Node0py vs Time');

% Plot z vs time
subplot(3,2,3);
plot(time, Node0pz);
xlabel('Time (s)');
ylabel('Node0pz');
title('Node0pz vs Time');

% Plot roll vs time
subplot(3,2,4);
plot(time, Node15px);
xlabel('Time (s)');
ylabel('Node15px');
title('Node15px vs Time');

% Plot pitch vs time
subplot(3,2,5);
plot(time, Node15py);
xlabel('Time (s)');
ylabel('Node15py');
title('Node15py vs Time');

% Plot yaw vs time
subplot(3,2,6);
plot(time, Node15pz);
xlabel('Time (s)');
ylabel('Node15pz');
title('Node15pz vs Time');

% Adjust layout
sgtitle('Quantities vs Time');

figure;
subplot(2,2,1);
plot(time, Seg1Te);
xlabel('Time (s)');
ylabel('Seg1Te');
title('Seg1Te vs Time');

% Plot y vs time
subplot(2,2,2);
plot(time, Seg2Te);
xlabel('Time (s)');
ylabel('Seg2Te');
title('Seg2Te vs Time');

% Plot z vs time
subplot(2,2,3);
plot(time, Seg14Te);
xlabel('Time (s)');
ylabel('Seg14Te');
title('Seg14Te vs Time');

% Plot roll vs time
subplot(2,2,4);
plot(time, Seg15Te);
xlabel('Time (s)');
ylabel('Seg15Te');
title('Seg15Te vs Time');

% Adjust layout
sgtitle('Quantities vs Time');

%% lines.out analysis

data2 = dlmread('Mooring/lines.out', '', 2, 0); % Replace 'data.out' with the name of your file
time = data2(:, 1);
FairTen1 = data2(:, 2);
FairTen2 = data2(:, 3);
FairTen3 = data2(:, 4);
AnchTen1 = data2(:, 4);

figure;
subplot(2,2,1);
plot(time, FairTen1);
xlabel('Time (s)');
ylabel('FairTen1');
title('FairTen1 vs Time');

% Plot y vs time
subplot(2,2,2);
plot(time, FairTen2);
xlabel('Time (s)');
ylabel('FairTen2');
title('FairTen2 vs Time');

% Plot z vs time
subplot(2,2,3);
plot(time, FairTen3);
xlabel('Time (s)');
ylabel('FairTen3');
title('FairTen3 vs Time');

% Plot roll vs time
subplot(2,2,4);
plot(time, AnchTen1);
xlabel('Time (s)');
ylabel('AnchTen1');
title('AnchTen1 vs Time');

sgtitle('Tensions vs Time');
