close all;clc; close all
hydro = struct();

hydro = readWAMIT(hydro,'spar.out',[]);
hydro = radiationIRF(hydro,15,[],[],1.5,6.25);
hydro = radiationIRFSS(hydro,[],[]);
hydro = excitationIRF(hydro,15,[],[],1.5,6.25);
writeBEMIOH5(hydro)
plotBEMIO(hydro)

