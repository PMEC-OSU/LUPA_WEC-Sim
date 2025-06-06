%Example of user input MATLAB file for post processing

%Plot waves
waves.plotElevation(simu.rampTime);
try 
    waves.plotSpectrum();
catch
end

%Plot heave response for body 1
output.plotResponse(1,3);
title('Float Heave Response')

%Plot heave response for body 2
output.plotResponse(2,3);
title('Spar Heave Response')


%Plot roll response for body 1
output.plotResponse(1,4);
title('Float roll Response')

%Plot roll response for body 2
output.plotResponse(2,4);
title('Spar roll Response')

%Plot pitch response for body 1
output.plotResponse(1,5);
title('Float pitch Response')

%Plot pitch response for body 2
output.plotResponse(2,5);
title('Spar pitch Response')

%Plot heave forces for body 1
output.plotForces(1,3);
title('Float Heave Forces')

%Plot heave forces for body 2
output.plotForces(2,3);
title('Spar Heave Forces')

% Spar position for mooring tension 
figure() 
plot(output.wave.time(:),output.bodies(2).position(:,3))
title('Spar position')

figure()
% Plot Mooring forces 
plot(output.wave.time(:),output.mooring.forceMooring(:,3))
title('Mooring Force')