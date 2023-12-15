%% LUPA Two-Body Heave-Only
% Fall 2022 Experimental Campaign

%% Simulation Data
simu=simulationClass();
simu.simMechanicsFile = 'LUPAsimTBHO.slx';
simu.endTime = 100;     
simu.rampTime = 20;
simu.dt = 0.01;    
simu.cicEndTime = 20;
simu.explorer = 'on';
simu.domainSize = 3.7/2;   % The domain is set to half of the flume width of 3.7 meters. 
%% Wave Information  
% Regular waves
waves = waveClass('regularCIC');                % Initialize waveClass
waves.height = 0.20;                            % [m] From Two-Body Heave-Only experiments
waves.period = 2;                               % [s]  1s to 3.25s Examples of periods used for LUPA 

%% Body Data
%% Body 1: Float
body(1) = bodyClass('..\hydroData\lupa.h5');
body(1).geometryFile = '..\geometry\LUPA_Fall2022_float_geometry.stl';
body(1).mass = 'equilibrium';
body(1).viz.color = [255/256 127/256 36/256];
body(1).inertia = [66.1686 65.3344 17.16];      % [kg-m^2] As measured from dry swing tests
body(1).quadDrag.cd = [0 0 0.15 0 0 0];         % [-] Quadratic drag coefficient Cd as found from Gu et al 2018
body(1).quadDrag.area = [0 0 pi*(0.5)^2 0 0 0]; % [m^2] Cross sectional area of body at water plane 

%% Body 2: Spar
body(2) = bodyClass('..\hydroData\lupa.h5');
body(2).geometryFile = '..\geometry\LUPA_Fall2022_spar_geometry.stl';
body(2).mass = 175.536;                             % [m] Set to equilibrium to achieve SWL at no wave condition due to positively bouyant spar.
body(2).viz.color = [211/256 211/256 211/256];
body(2).inertia = [253.6344  250.4558 12.746];      % [kg-m^2] As measured from dry swing tests
body(2).quadDrag.cd = [0 0 2.8 0 0 0];              % [-] Quadratic drag coefficient Cd as found from Beatty 2015
body(2).quadDrag.area = [0 0 pi*(0.45)^2 0 0 0];    % [m^2] Cross sectional area of body at water plane
body(2).linearDamping(3,3) = 700;                   % [N/m/s] Linear damping  Found experimentally through free decay tests. It is negative because it is a mechanical loss from the heave constraint.
body(2).setInitDisp([0 0 0],[0 0 0 0],[0 0 -0.67]); % [m] Initial Displacement  Set to engage mooring lines for pre-tension.

%% PTO and Constraint Parameters
% Translational Joint
constraint(1) = constraintClass('Constraint1');     % Initialize Constraint Class for Constraint1
constraint(1).location = [0 0 0];                   % [m] Constraint Location 

% Translational PTO
pto(1) = ptoClass('PTO1');                          % Initialize PTO Class for PTO1
pto(1).stiffness = 0;                               % [N/m] PTO Stiffness 
pto(1).damping = 0;                                 % [N/(m/s)] PTO Damping  Typical values fall between 0-10,000 N/(m/s)                        
ptoDampingLoss = -350;                              % [N/m/s] Linear damping  Found experimentally through free decay tests. It is negative because it is a electromechanical loss.
pto(1).location = [0 0 0];                          % [m] PTO Location 

%% Mooring Matrix
mooring(1) = mooringClass('mooring');           % Initialize mooringClass
mooring(1).matrix.stiffness(3,3) = 253.36;      % [N/m] This is the combined heave stiffness of all 4 mooring springs as calculated from their equilbrium location and angle.
mooring(1).location = [0 0 -0.76-0.67];         % [m] Distance in meters from the still water line down to the mooring connection point when the spar is initially displaced.

