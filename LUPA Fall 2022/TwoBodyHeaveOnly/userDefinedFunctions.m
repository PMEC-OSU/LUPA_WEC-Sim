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

%Plot heave forces for body 1
output.plotForces(1,3);
title('Float Heave Forces')

%Plot heave forces for body 2
output.plotForces(2,3);
title('Spar Heave Forces')
