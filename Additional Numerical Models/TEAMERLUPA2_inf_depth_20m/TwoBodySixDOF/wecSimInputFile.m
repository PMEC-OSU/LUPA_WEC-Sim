%% LUPA Two-Body Six-DOF
% 20x Model of TEAMERLUPA2 
% TEAMERLUPA2 Experimental Campaign Fall 2023
% 
% Water depth set to infinite
% 
% Created by Hannah Mankle
% Last modified: 05/29/2025 


%% Simulation Data
simu=simulationClass();
simu.simMechanicsFile = 'LUPAsimTBSD.slx';
simu.endTime = 300;     
simu.rampTime = 30;
simu.dt = 0.01;    
simu.cicEndTime = 20;
simu.explorer = 'on';
simu.domainSize = 74/2;   % The domain is set to half of the 20x scaled flume width of 74 meters. 

%% Wave Information  
waves = waveClass('noWave');
waves.period = 10;

% Regular waves
% waves = waveClass('regularCIC');      % Initialize waveClass
% waves.height = 3;                     % [m] From Two-Body Six-DOF experiments
% waves.period = 10;                    % [s]  1s to 3.25s Examples of periods used for LUPA 


% Regular waves
% waves = waveClass('irregular');                   % Initialize waveClass
% waves.spectrumType = ('PM');
% waves.height = 0.06;                            % [m] From Two-Body Six-DOF experiments
% waves.period = 3;  

%% Body Data
%% Body 1: Float
body(1) = bodyClass('..\hydroData\floatspar_20m.h5');
body(1).geometryFile = '..\geometry\LUPA_float_20m.stl';
body(1).mass = 'equilibrium';
body(1).viz.color = [255/256 127/256 36/256];
body(1).inertia = [206720000 208192000 57056000];       % [kg-m^2] scaled 20x from Lab-scale measured dry swing tests
body(1).quadDrag.cd = [0.54 0.54 0.15 0.54 0.54 0.15];  % [-] Quadratic drag coefficient Cd as found from Gu et al 2018
body(1).quadDrag.area = [73 73 314.16 73 73 314.16];    % [m^2] Characteristic area in relevant plane 

%% Body 2: Spar
body(2) = bodyClass('..\hydroData\floatspar_20m.h5');
body(2).geometryFile = '..\geometry\LUPA_spar_20m_full.stl';
body(2).mass = 1617680;   %'equilibrium';                        % [kg] Positively bouyant spar. Scaled 20x
body(2).viz.color = [211/256 211/256 211/256];
body(2).inertia = [975315200 976800000 50480000];                % [kg-m^2] scaled 20x from Lab-scale measured dry swing tests
body(2).quadDrag.cd = [0.6 0.6 2.8 0.6 0.6 2.8];                 % [-] Quadratic drag coefficient Cd as found from Beatty 2015 and Singh & Mittal 2005
body(2).quadDrag.area = [103.78 103.78 130 103.78 103.78 130];   % [m^2] Characteristic area in relevant plane
body(2).setInitDisp([0 0 0],[0 0 0 0],[0 0 -0.6]);               % [m] Initial Displacement  Set to engage mooring lines for pre-tension.

%% PTO and Constraint Parameters
% NEED TO SCALE PTO DAMPING LOSS

% Translational Joint
constraint(1) = constraintClass('Constraint1');         % Initialize Constraint Class for Constraint1
constraint(1).location = [0 0 0];                       % [m] Constraint Location 

% Translational PTO
pto(1) = ptoClass('PTO1');                              % Initialize PTO Class for PTO1
pto(1).stiffness = 0;                                   % [N/m] PTO Stiffness 
pto(1).damping = 0;                                     % [N/(m/s)] PTO Damping. Typical values fall between 0-10,000 N/(m/s)                       
ptoDampingLoss = -626099;                               % [N/m/s] Linear damping. Scaled 20x experimentally found values from free decay tests. It is negative because it is a electromechanical loss.
pto(1).location = [0 0 0];                              % [m] PTO Location 

%% Mooring Matrix

R = 6.5;                                   % [m] Radius of mooring plate scaled 10x
mooring(1) = mooringClass('mooring');       % Initialize mooringClass

%%This is the combined equivalent stiffness of all 4 springs as calculated
%%from their equilbrium location and angle. Scaled up 20x from lab-scale
mooring(1).matrix.stiffness(1,1) = 1145600;   % [N/m]
mooring(1).matrix.stiffness(2,2) = 1145600;   % [N/m]
mooring(1).matrix.stiffness(3,3) = 224800;   % [N/m] 
mooring(1).matrix.stiffness(4,4) = 32712000*R;   % [N/deg] Assumming small angle approximations acting axially
mooring(1).matrix.stiffness(5,5) = 32712000*R;   % [N/deg] Assumming small angle approximations acting axially
mooring(1).matrix.stiffness(6,6) = 32712000*R;   % [N/deg] Assumming small angle approximations acting axially
mooring(1).location = [0 0 -14.4-0.6];      % [m] Distance in meters from the still water line down to the mooring connection point when the spar is initially displaced.
