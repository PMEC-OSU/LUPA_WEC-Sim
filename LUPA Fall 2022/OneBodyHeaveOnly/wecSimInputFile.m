%% LUPA One-Body Heave-Only
% Fall 2022 Experimental Campaign

%% Simulation Data
simu=simulationClass();
simu.simMechanicsFile = 'LUPAsimOBHO.slx';
simu.endTime = 100;     
simu.rampTime = 20;
simu.dt = 0.01;    
simu.cicEndTime = 20;
simu.explorer = 'on';
simu.domainSize = 3.7/2;   % The domain is set to half of the flume width of 3.7 meters.

%% Wave Information  
% Regular waves
waves = waveClass('regularCIC');                % Initialize waveClass
waves.height = 0.20;                            % [m] From One-Body Heave-Only experiments
waves.period = 2;                               % [s]  1s to 3.25s Examples of periods used for LUPA
                               
%% Body Data
%% Body 1: Float
body(1) = bodyClass('..\hydroData\lupa.h5');
body(1).geometryFile = '..\geometry\LUPA_Fall2022_float_geometry.stl';
body(1).mass = 'equilibrium';
body(1).viz.color = [255/256 127/256 36/256];
body(1).inertia = [66.1686 65.3344 17.16];          % [kg-m^2] As measured from dry swing tests
body(1).quadDrag.cd = [0 0 0.15 0 0 0];             % [-] Quadratic drag coefficient Cd as found from Gu et al 2018
body(1).quadDrag.area = [0 0 pi*(0.5)^2 0 0 0];     % [m^2] Cross sectional area of body at water plane 
 
%% PTO and Constraint Parameters
% Translational PTO
pto(1) = ptoClass('PTO1');                      % Initialize PTO Class for PTO1
pto(1).stiffness = 0;                           % [N/m] PTO Stiffness 
pto(1).damping = 0;                             % [N/(m/s)] PTO Damping  Typical values fall between 0-10,000 N/(m/s)
pto(1).location = [0 0 0];                      % [m] PTO Location 
ptoDampingLoss = -350;                          % [N/m/s] Linear damping  Found experimentally through free decay tests. It is negative because it is a electromechanical loss.

