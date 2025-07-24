%Example of user input MATLAB file for post processing
%Uncomment portions of this code to output more data

%Plot waves
% waves.plotElevation(simu.rampTime);
% try 
%     waves.plotSpectrum();
% catch
% end

%Plot heave response for body 1
output.plotResponse(1,3);
title('Float Heave Response')

%Plot heave response for body 2
output.plotResponse(2,3);
title('Spar Heave Response')

%Plot heave forces for body 1
% output.plotForces(1,3);
% title('Float Heave Forces')

%Plot heave forces for body 2
% output.plotForces(2,3);
% title('Spar Heave Forces')

%Plot line 1 tensions
% figure()
% plot(output.moorDyn.Lines.Time,output.moorDyn.Lines.FairTen1)
% xlabel('time (sec)')
% ylabel('Force (N)')
% title('Fairlead Line Tension')
% figure()
% plot(output.moorDyn.Lines.Time,output.moorDyn.Lines.AnchTen1)
% xlabel('time (sec)')
% ylabel('Force (N)')
% title('Anchor Line Tension')