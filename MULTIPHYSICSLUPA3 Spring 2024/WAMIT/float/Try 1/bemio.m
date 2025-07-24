close all;clc; close all
hydro = struct();

hydro = readWAMIT(hydro,'float.out',[]);
hydro = radiationIRF(hydro,10,[],[],[],[]);
hydro = radiationIRFSS(hydro,[],[]);
hydro = excitationIRF(hydro,10,[],[],[],[]);
% hydro = readWAMIT(hydro,'float12.out',[]);
% hydro = combineBEM(hydro);
% writeBEMIOH5(hydro)
plotBEMIO(hydro)
