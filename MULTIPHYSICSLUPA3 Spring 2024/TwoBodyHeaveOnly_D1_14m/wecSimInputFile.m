%% LUPA Two-Body Six-DOF - Large Heave Plate
% MultiphysicsLUPA3 Experimental Campaign Spring 2024
% Same LUPA model as TEAMERLUPA2 Fall 2023 campagin with varying heave
% plate diameters
%
% Heave plate diameter is 1.14 m   
% Depth is set at 2.78 m 
% 
% Updated by: Hannah Mankle 6/6/2025

%% Simulation Data
simu=simulationClass();
simu.simMechanicsFile = 'LUPAsimTBSD.slx';
simu.endTime = 100;     
simu.rampTime = 20;
simu.dt = 0.01;    
simu.cicEndTime = 10;
simu.explorer = 'on';
simu.domainSize = 3.7/2;   % The domain is set to half of the flume width of 3.7 meters. 

%% Wave Information  
waves = waveClass('noWave');
waves.period = 2;

% % Regular waves
% waves = waveClass('regularCIC');                   % Initialize waveClass
% waves.height = 0.06;                            % [m] From Two-Body Six-DOF experiments
% waves.period = 2;                               % [s]  1s to 3.25s Examples of periods used for LUPA 

%% Body Data
%% Body 1: Float
body(1) = bodyClass('..\hydroData\floatspar_D1_14m_d2_78m.h5');
body(1).geometryFile = '..\geometry\LUPA_Fall2022_float_geometry.stl';
body(1).mass = 'equilibrium';
body(1).viz.color = [255/256 127/256 36/256];
body(1).inertia = [64.60 65.06 17.83];                      % [kg-m^2] As measured from dry swing tests
body(1).quadDrag.cd = [0.54 0.54 0.15 0.54 0.54 0.15];          % [-] Quadratic drag coefficient Cd as found from Gu et al 2018
body(1).quadDrag.area = [0.368 0.368 0.785 0.368 0.368 0.785];  % [m^2] Characteristic area in relevant plane

%% Body 2: Spar
body(2) = bodyClass('..\hydroData\floatspar_D1_14m_d2_78m.h5');
body(2).geometryFile = '..\geometry\LUPA_spar_D1_14m_full.stl';
body(2).mass = 202.21;                                             % [kg] Positively bouyant spar.
body(2).viz.color = [211/256 211/256 211/256];
body(2).inertia = [304.786 305.250 15.775];                      % [kg-m^2] As measured from dry swing tests
body(2).quadDrag.cd = [0.6 0.6 2.8 0.6 0.6 2.8];                    % [-] Quadratic drag coefficient Cd as found from Beatty 2015 and Singh & Mittal 2005
body(2).quadDrag.area = [0.558 0.558 0.636 0.558 0.558 0.636];      % [m^2] Characteristic area in relevant plane
body(2).setInitDisp([0 0 0],[0 0 0 0],[0 0 -0.22]);                 % [m] Initial Displacement  Set to engage mooring lines for pre-tension.

%% PTO and Constraint Parameters
% Translational Joint
constraint(1) = constraintClass('Constraint1');         % Initialize Constraint Class for Constraint1
constraint(1).location = [0 0 0];                       % [m] Constraint Location 

% Translational PTO
pto(1) = ptoClass('PTO1');                              % Initialize PTO Class for PTO1
pto(1).stiffness = 0;                                   % [N/m] PTO Stiffness 
pto(1).damping = 0;                                     % [N/(m/s)] PTO Damping  Typical values fall between 0-10,000 N/(m/s)                       
ptoDampingLoss = -350;                                  % [N/m/s] Linear damping  Found experimentally through free decay tests. It is negative because it is a electromechanical loss.
pto(1).location = [0 0 0];                              % [m] PTO Location 

%% Mooring Matrix
R = 0.325;                                   % [m] Radius of mooring plate
mooring(1) = mooringClass('mooring');       % Initialize mooringClass

%%This is the combined equivalent stiffness of all 4 springs as calculated from their equilbrium location and angle.
mooring(1).matrix.stiffness(1,1) = 2864;   % [N/m]
mooring(1).matrix.stiffness(2,2) = 2864;   % [N/m]
mooring(1).matrix.stiffness(3,3) = 562;   % [N/m] 
mooring(1).matrix.stiffness(4,4) = 4089*R;   % [N/deg] Assumming small angle approximations acting axially
mooring(1).matrix.stiffness(5,5) = 4089*R;   % [N/deg] Assumming small angle approximations acting axially
mooring(1).matrix.stiffness(6,6) = 4089*R;   % [N/deg] Assumming small angle approximations acting axially
mooring(1).location = [0 0 -0.72-0.22];      % [m] Distance in meters from the still water line down to the mooring connection point when the spar is initially displaced.
