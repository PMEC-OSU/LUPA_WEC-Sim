%% LUPA Two-Body Six-DOF
% Fall 2022 Experimental Campaign

%% Simulation Data
simu=simulationClass();
simu.simMechanicsFile = 'LUPA_MHKDR.slx'; 
simu.endTime = 100;     
simu.rampTime = 20;
simu.dt = 0.1;    
simu.cicEndTime = 20;
simu.explorer = 'on';
simu.domainSize = 3.7/2;   % The domain is set to half of the flume width of 3.7 meters. 
%% Wave Information  
% Regular waves
waves = waveClass('regular');                   % Initialize waveClass
waves.height = 0.25;                            % [m] From Two-Body Six-DOF experiments
waves.period = 2;                               % [s]  1s to 3.25s Examples of periods used for LUPA 
waves.waterDepth = 3.7;

% waves = waveClass('noWaveCIC');                   % Optional No Wave Case
%% Body Data
%% Body 1: Float
body(1) = bodyClass('hydroData\LUPA_Hydro.h5');
body(1).geometryFile = 'geometry\float.stl';
body(1).mass = 'equilibrium';
body(1).viz.color = [255/256 127/256 36/256];
body(1).inertia = [66.1686 66.1686 17.16];                      % [kg-m^2] As measured from dry swing tests
body(1).quadDrag.cd = [0.54 0.54 0.15 0.54 0.54 0.15];          % [-] Quadratic drag coefficient Cd as found from Gu et al 2018
body(1).quadDrag.area = [0.368 0.368 0.785 0.368 0.368 0.785];  % [m^2] Cross sectional area of body at water plane 
body(1).initial.displacement = [ 0 0 0];
body(1).linearDamping = [0.7 0 0 0 0 0; 0 0.7 0 0 0 0; 0 0 1.22 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0.22 0; 0 0 0 0 0 0 ];

%% Body 2: Spar
body(2) = bodyClass('hydroData\LUPA_Hydro.h5');
body(2).geometryFile = 'geometry\spar.stl';
body(2).mass = 'equilibrium';                                             % [m] Positively bouyant spar.
body(2).viz.color = [211/256 211/256 211/256];
body(2).inertia = [250.4558  250.4558 12.746];                      % [kg-m^2] As measured from dry swing tests
body(2).quadDrag.cd = [0.65 0.65 2.85 0.65 0.65 2.85];                    % [-] Quadratic drag coefficient Cd as found from Beatty 2015 and Singh & Mittal 2005
body(2).quadDrag.area = [0.592 0.592 0.636 0.592 0.592 0.636];      % [m^2] Cross sectional area of body at water plane 
body(2).initial.displacement = [ 0 0 0];
body(2).linearDamping = [0.7 0 0 0 0 0; 0 0.7 0 0 0 0; 0 0 1.22 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0.22 0; 0 0 0 0 0 0 ];

%% PTO and Constraint Parameters
% Translational Joint
constraint(1) = constraintClass('Constraint1');         % Initialize Constraint Class for Constraint1
constraint(1).location = [0 0 0];                       % [m] Constraint Location 

% Translational PTO
pto(1) = ptoClass('PTO1');                              % Initialize PTO Class for PTO1
pto(1).stiffness = 350;                                   % [N/m] PTO Stiffness 
pto(1).damping = 100;                                     % [N/(m/s)] PTO Damping  Typical values fall between 0-10,000 N/(m/s)                       
ptoDampingLoss = -350;                                  % [N/m/s] Linear damping  Found experimentally through free decay tests. It is negative because it is a electromechanical loss.
pto(1).location = [0 0 0];                              % [m] PTO Location 

%% MoorDyn
mooring(1) = mooringClass('mooring');       % Initialize mooringClass
mooring(1).moorDyn = 1;
mooring(1).moorDynInputFile = 'Mooring\lines.txt';