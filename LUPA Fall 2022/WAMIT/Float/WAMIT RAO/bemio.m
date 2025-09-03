close all;clc; close all
hydro = struct();

hydro = readWAMIT(hydro,'float.out','rao');
hydro = radiationIRF(hydro,20,[],[],0.3,7);
hydro = radiationIRFSS(hydro,[],[]);
hydro = excitationIRF(hydro,20,[],[],0.3,7);
writeBEMIOH5(hydro)
plotBEMIO(hydro)

