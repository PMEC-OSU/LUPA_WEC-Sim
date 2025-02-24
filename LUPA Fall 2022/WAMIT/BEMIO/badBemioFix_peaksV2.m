% Dominic D. Forbush 

% Copyright Sandia National Laboratories 2023. DO NOT DISTRIBUTE.

% this is a fixer script for BEMIO coefficients
% V2: adds the averaging procedure for hyperbolic peaks
% 
%% This has to be run from the WAMIT directory to work properly, otherwise
% the bemio call won't work.
close all; clear; clc
% first call BEMIO
hydro = struct();
hydro = readWAMIT(hydro,'float.out',[]);
hydro = readWAMIT(hydro,'spar.out',[]);
hydro = combineBEM(hydro);
dw=mean(diff(hydro.w));

%% de-spiking parameters
% you can still specify other arguments of findpeaks when the function is
% called, bhese are just the only ones. 

% maxPeakWidth is not recommended however as it has unexpected behavior
deSpike=struct();
deSpike.negThresh = 1e-3; % the threshold below which negative damping will be removed
deSpike.N = 5; % will loop the despiking procedure N time before filtering
deSpike.appFilt = 1; % boolean, 1 to apply low pass filter after despiking

% thresholds: applied to 'Threshold' argument of findpeaks
deSpike.Threshold.B = 2e-4; % damping
deSpike.Threshold.A = 1e-3; % added mass
deSpike.Threshold.ExRe = 1e-3; % real part excitation
deSpike.Threshold.ExIm = 1e-3; % imag part excitation

% minimum peak prominence, applied to 'MinPeakProminence' argument of findpeaks 
deSpike.Prominence.B = 2e-4;  
deSpike.Prominence.A = 1e-3; 
deSpike.Prominence.ExRe = 1e-3;  
deSpike.Prominence.ExIm = 1e-3; 

% minimum peak distance, applied to 'MinPeakDistance' argument of findpeaks 
deSpike.MinPeakDistance.A = 3;
deSpike.MinPeakDistance.B = 3;
deSpike.MinPeakDistance.ExRe = 3;
deSpike.MinPeakDistance.ExIm = 3;

debugPlot =1; % set 1 to make excitation debug plots.
%% calc original IRF and plot
hydro = radiationIRF(hydro,30,[],[],0.3,7);
hydro = radiationIRFSS(hydro,30,[]);
hydro = excitationIRF(hydro,30,[],[],0.3,7);
writeBEMIOH5(hydro);
hydro.plotDofs = [1,1;3,3;5,5;7,7;3,7;7,3];
plotBEMIO(hydro);

%% filtering parameters
%%% recommend using the filter design application
% d=designfilt('lowpassiir', 'FilterOrder',2,...
%     'PassbandFrequency',15,...
%     'SampleRate',(2*pi)/dw);
%filtNum = 5;
b = 0.02008336556421123561544384017452102853 .* [1 2 1];
a = [1 -1.561018075800718163392843962355982512236     0.641351538057563175243558362126350402832];



%% rad and mass fixes
[row,col,~]=size(hydro.B);
% parse negative radiation damping
for k=1:row;
    for kk=1:col
        bPks(k,kk) = max(squeeze(hydro.B(k,kk,:)));
        p1Idx = find(abs(hydro.B(k,kk,:)) > deSpike.negThresh * bPks(k,kk));
        p2Idx = find(hydro.B(k,kk,:) < 0);
        pIdx = intersect(p1Idx,p2Idx);
        hydro.B(k,kk,pIdx) = 0;
    end
end

for k =1:row
    for kk=1:col
        for it = deSpike.N
            % positive peaks
            testB = squeeze(hydro.B(k,kk,:));
            [BPeaks,BLocs]= findpeaks(testB,'MinPeakProminence',deSpike.Prominence.B,'Threshold',deSpike.Threshold.B,'MinPeakDistance',deSpike.MinPeakDistance.B);
            BLocs(BLocs>length(testB)-2) = []; % trim end extrema
            BLocs(BLocs<2) = []; % trim start extrema
            testA = squeeze(hydro.A(k,kk,:)); %
            [APeaks,ALocs] = findpeaks(testA,'MinPeakProminence',deSpike.Prominence.A,'Threshold',deSpike.Threshold.A,'MinPeakDistance',deSpike.MinPeakDistance.A);
            %%% There is a "maxPeakWidth" argument: this does not work as
            %%% the developer intends and is not recommended for use.
            ALocs(ALocs>length(testA)-2) = [];
            ALocs(ALocs<2) = []; % trim start extrema

            % negative peaks
            [BPeaksN,BLocsN]= findpeaks(-1.*testB,'MinPeakProminence',deSpike.Prominence.B,'Threshold',deSpike.Threshold.B,'MinPeakDistance',deSpike.MinPeakDistance.B);
            BLocsN(BLocsN>length(testB)-2) = []; % trim end extrema
            BLocsN(BLocsN<2) = []; % trim start extrema
            [APeaksN,ALocsN] = findpeaks(-1.*testA,'MinPeakProminence',deSpike.Prominence.A,'Threshold',deSpike.Threshold.A,'MinPeakDistance',deSpike.MinPeakDistance.A);
            ALocsN(ALocsN>length(testA)-2) = [];
            ALocsN(ALocsN<2) = []; % trim start extrema

            % smooth hyperbolic peaks via averaging
            BLog = [];
            BLogN = [];
            for kkk=1:length(BLocs) % B location pchip smoothing
                % check for consecutive +/- peaks, average them
                hidx = find(abs(BLocsN-BLocs(kkk))<(2+it-1),1); % finds a consecutive positive/negative hyperbolic peaks
                if ~isempty(hidx)
                   BLog = [BLog; kkk];  
                   BLogN = [BLogN; hidx];
                   BRep = mean([BPeaks(kkk);-1.*BPeaksN(hidx)]);
                   hydro.B(k,kk,BLocs(kkk)) = BRep; % replace both high and low peak with mean value
                   hydro.B(k,kk,BLocsN(hidx)) = BRep;
                   % remove these corrected peaks from despiking this
                   % iteration
                end
            end
            BPeaks(BLog) = []; BLocs(BLog)=[]; BPeaksN(BLogN) = []; BLocsN(BLogN)=[];
            %%% It is possible to condense the redundant for loop to
            %%% reduce run time but this comes at the cost of messier syntax
            % each iteration this will replace both the high and low peaks
            % with their average value. This will not eliminate smaller
            % peaks, but these will not be caught with successive
            % iterations unless the averaging window expands, hence 2+it-1

            % smooth positive peaks via interpolation amongst surrounding
            % points
            for kkk=1:length(BLocs)
                BRep = interp1([hydro.w(BLocs(kkk)-2);hydro.w(BLocs(kkk)-1);hydro.w(BLocs(kkk)+1);hydro.w(BLocs(kkk)+2)],...
                    [hydro.B(k,kk,BLocs(kkk)-2);hydro.B(k,kk,BLocs(kkk)-1);hydro.B(k,kk,BLocs(kkk)+1);hydro.B(k,kk,BLocs(kkk)+2)],hydro.w(BLocs(kkk)),'linear');
                hydro.B(k,kk,BLocs(kkk))=BRep;
            end

            ALog = [];
            ALogN = [];
           for kkk=1:length(ALocs) % B location pchip smoothing
                % check for consecutive +/- peaks, average them
                hidx = find(abs(ALocsN-ALocs(kkk))<(2+it-1),1); % finds a consecutive positive/negative hyperbolic peaks
                if ~isempty(hidx)
                   ALog = [ALog; kkk];
                   ALogN = [ALogN; hidx];
                   ARep = mean([APeaks(kkk);-1.*APeaksN(hidx)]); % flips N peaks back to correct sign 
                   hydro.A(k,kk,ALocs(kkk)) = ARep; % replace both high and low peak with mean value
                   hydro.A(k,kk,ALocsN(hidx)) = ARep;
                   % remove these corrected peaks from despiking this
                   % iteration
                end
           end
           APeaks(ALog) = []; ALocs(ALog)=[]; APeaksN(ALogN) = []; ALocsN(ALogN)=[];
            % smooth positive peaks via interpolation amongst surrounding
            % points
            for kkk=1:length(ALocs) % A location pchip smoothing
                ARep =interp1([hydro.w(ALocs(kkk)-2),hydro.w(ALocs(kkk)-1),hydro.w(ALocs(kkk)+1),hydro.w(ALocs(kkk)+2)],...
                    [hydro.A(k,kk,ALocs(kkk)-2),hydro.A(k,kk,ALocs(kkk)-1),hydro.A(k,kk,ALocs(kkk)+1),hydro.A(k,kk,ALocs(kkk)+2)],hydro.w(ALocs(kkk)),'linear');
                hydro.A(k,kk,ALocs(kkk))=ARep;
            end

            % smooth negative peaks via interpolation amongst surrounding
            % points
            for kkk=1:length(BLocsN) % B location pchip smoothing
                BRep = interp1([hydro.w(BLocsN(kkk)-2);hydro.w(BLocsN(kkk)-1);hydro.w(BLocsN(kkk)+1);hydro.w(BLocsN(kkk)+2)],...
                    [hydro.B(k,kk,BLocsN(kkk)-2);hydro.B(k,kk,BLocsN(kkk)-1);hydro.B(k,kk,BLocsN(kkk)+1);hydro.B(k,kk,BLocsN(kkk)+2)],hydro.w(BLocsN(kkk)),'linear');
                hydro.B(k,kk,BLocsN(kkk))=BRep;
            end
            for kkk=1:length(ALocsN) % A location pchip smoothing
                ARep =interp1([hydro.w(ALocsN(kkk)-2),hydro.w(ALocsN(kkk)-1),hydro.w(ALocsN(kkk)+1),hydro.w(ALocsN(kkk)+2)],...
                    [hydro.A(k,kk,ALocsN(kkk)-2),hydro.A(k,kk,ALocsN(kkk)-1),hydro.A(k,kk,ALocsN(kkk)+1),hydro.A(k,kk,ALocsN(kkk)+2)],hydro.w(ALocsN(kkk)),'linear');
                hydro.A(k,kk,ALocsN(kkk))=ARep;
            end
            clear testA testB BLocs BPeaks ALocs APeaks BLocsN BPeaksN ALocsN APeaksN
        end
        if deSpike.appFilt ==1;
            B_smooth(k,kk,:) = filtfilt(b,a,squeeze(hydro.B(k,kk,:)));
            A_smooth(k,kk,:) = filtfilt(b,a,squeeze(hydro.A(k,kk,:)));
        end
    end
end

%% excitation fixes
for k=1:row
    for it =1:deSpike.N
        % real part despiking
        test = squeeze(hydro.ex_re(k,1,:));
        [ExPeaks,ExLocs] = findpeaks(test,'MinPeakProminence',deSpike.Prominence.ExRe,'Threshold',deSpike.Threshold.ExRe,'MinPeakDistance',deSpike.MinPeakDistance.ExRe);
        ExLocs(ExLocs>length(test)-2) = [];
        ExLocs(ExLocs<2) = [];
        [ExPeaksN,ExLocsN] = findpeaks(-.1*test,'MinPeakProminence',deSpike.Prominence.ExRe,'Threshold',deSpike.Threshold.ExRe,'MinPeakDistance',deSpike.MinPeakDistance.ExRe);
        ExLocsN(ExLocsN>length(test)-2) = [];
        ExLocsN(ExLocsN<2) = [];
        
        ExLog=[]; ExLogN = [];
        for kk=1:length(ExLocs)
            hidx = find(abs(ExLocsN-ExLocs(kk))<2,1);
            if ~isempty(hidx)
                ExLog = [ExLog; kk];
                ExLogN = [ExLogN; hidx];
                ExRep = mean([-1.*ExPeaksN(hidx);ExPeaks(kk)]);
                hydro.ex_re(k,1,ExLocs(kk))=ExRep;
                hydro.ex_re(k,1,ExLocsN(hidx))=ExRep;
            end
        end
        ExPeaks(ExLog) = []; ExLocs(ExLog)=[]; ExPeaksN(ExLogN) = []; ExLocsN(ExLogN)=[];

        for kk =1:length(ExLocs) % real part positive peaks
            ExRep = interp1([hydro.w(ExLocs(kk)-2),hydro.w(ExLocs(kk)-1),hydro.w(ExLocs(kk)+1),hydro.w(ExLocs(kk)+2)],...
                [hydro.ex_re(k,1,ExLocs(kk)-2),hydro.ex_re(k,1,ExLocs(kk)-1),hydro.ex_re(k,1,ExLocs(kk)+1),hydro.ex_re(k,1,ExLocs(kk)+2)],hydro.w(ExLocs(kk)),'linear');
            hydro.ex_re(k,1,ExLocs(kk)) = ExRep;
        end

        for kk =1:length(ExLocsN) % real part negative peaks
            ExRep = interp1([hydro.w(ExLocsN(kk)-2),hydro.w(ExLocsN(kk)-1),hydro.w(ExLocsN(kk)+1),hydro.w(ExLocsN(kk)+2)],...
                [hydro.ex_re(k,1,ExLocsN(kk)-2),hydro.ex_re(k,1,ExLocsN(kk)-1),hydro.ex_re(k,1,ExLocsN(kk)+1),hydro.ex_re(k,1,ExLocsN(kk)+2)],hydro.w(ExLocsN(kk)),'linear');
            hydro.ex_re(k,1,ExLocsN(kk)) = ExRep;
        end

        % imaginary part despiking
        test = squeeze(hydro.ex_im(k,1,:));
        [ExPeaks,ExLocs] = findpeaks(test,'MinPeakProminence',deSpike.Prominence.ExIm,'Threshold',deSpike.Threshold.ExIm,'MinPeakDistance',deSpike.MinPeakDistance.ExIm);
        ExLocs(ExLocs>length(test)-2) = [];
        ExLocs(ExLocs<2) = [];

        [ExPeaksN,ExLocsN] = findpeaks(-.1*test,'MinPeakProminence',deSpike.Prominence.ExIm,'Threshold',deSpike.Threshold.ExIm,'MinPeakDistance',deSpike.MinPeakDistance.ExIm);
        ExLocsN(ExLocsN>length(test)-2) = [];
        ExLocsN(ExLocsN<2) = [];

        ExLog=[]; ExLogN = [];
        for kk=1:length(ExLocs)
            hidx = find(abs(ExLocsN-ExLocs(kk))<2,1);
            if ~isempty(hidx)
                ExLog = [ExLog; kk];
                ExLogN = [ExLogN; hidx];
                ExRep = mean([-1.*ExPeaksN(hidx); ExPeaks(kk)]);
                hydro.ex_re(k,1,ExLocs(kk))=ExRep;
                hydro.ex_re(k,1,ExLocsN(hidx))=ExRep;
            end
        end
        ExPeaks(ExLog) = []; ExLocs(ExLog)=[]; ExPeaksN(ExLogN) = []; ExLocsN(ExLogN)=[];
       
        for kk =1:length(ExLocs) % real part positive peaks
            ExRep = interp1([hydro.w(ExLocs(kk)-2),hydro.w(ExLocs(kk)-1),hydro.w(ExLocs(kk)+1),hydro.w(ExLocs(kk)+2)],...
                [hydro.ex_im(k,1,ExLocs(kk)-2),hydro.ex_im(k,1,ExLocs(kk)-1),hydro.ex_im(k,1,ExLocs(kk)+1),hydro.ex_im(k,1,ExLocs(kk)+2)],hydro.w(ExLocs(kk)),'linear');
            hydro.ex_im(k,1,ExLocs(kk)) = ExRep;
        end

        for kk =1:length(ExLocsN) % imaginary part negative peaks
            ExRep = interp1([hydro.w(ExLocsN(kk)-2),hydro.w(ExLocsN(kk)-1),hydro.w(ExLocsN(kk)+1),hydro.w(ExLocsN(kk)+2)],...
                [hydro.ex_im(k,1,ExLocsN(kk)-2),hydro.ex_im(k,1,ExLocsN(kk)-1),hydro.ex_im(k,1,ExLocsN(kk)+1),hydro.ex_im(k,1,ExLocsN(kk)+2)],hydro.w(ExLocsN(kk)),'linear');
            hydro.ex_im(k,1,ExLocsN(kk)) = ExRep;
        end
        %     sc_ma_smooth(row,1,:) = filtfilt(b,a,squeeze(hydro.sc_ma(k,1,:)));
        %     sc_ph_smooth(row,1,:) = filtfilt(b,a,squeeze(hydro.sc_ph(k,1,:)));
        %     sc_re_smooth(row,1,:) = filtfilt(b,a,squeeze(hydro.sc_re(k,1,:)));
        %     sc_im_smooth(row,1,:) = filtfilt(b,a,squeeze(hydro.sc_im(k,1,:)));
        %     fk_ma_smooth(row,1,:) = filtfilt(b,a,squeeze(hydro.fk_ma(k,1,:)));
        %     fk_ph_smooth(row,1,:) = filtfilt(b,a,squeeze(hydro.fk_ph(k,1,:)));
        %     fk_re_smooth(row,1,:) = filtfilt(b,a,squeeze(hydro.fk_re(k,1,:)));
        %     fk_im_smooth(row,1,:) = filtfilt(b,a,squeeze(hydro.fk_im(k,1,:)));

        clear test ExLocs ExPeaks ExLocsN ExPeaksN

       
end
if deSpike.appFilt==1;
    %ex_ma_smooth(k,1,:) = filtfilt(b,a,squeeze(hydro.ex_ma(k,1,:)));
    %ex_ph_smooth(k,1,:) = filtfilt(b,a,squeeze(hydro.ex_ph(k,1,:)));
    ex_re_smooth(k,1,:) = filtfilt(b,a,squeeze(hydro.ex_re(k,1,:)));
    ex_im_smooth(k,1,:) = filtfilt(b,a,squeeze(hydro.ex_im(k,1,:)));
end
end

if deSpike.appFilt ==1
    hydro.A = A_smooth;
    hydro.B = B_smooth;
   %hydro.ex_ma = ex_ma_smooth;
    %hydro.ex_ph = ex_ph_smooth;
    hydro.ex_re = ex_re_smooth;
    hydro.ex_im = ex_im_smooth;
end
% hydro.sc_ma = sc_ma_smooth;
% hydro.sc_ph = sc_ph_smooth;
% hydro.sc_re = sc_re_smooth;
% hydro.sc_im = sc_im_smooth;
% hydro.fk_ma = fk_ma_smooth;
% hydro.fk_ph = fk_ph_smooth;
% hydro.fk_re = fk_re_smooth;
% hydro.fk_im = fk_im_smooth;

hydro = radiationIRF(hydro,20,[],[],0.3,7);
hydro = radiationIRFSS(hydro,20,[]);
hydro = excitationIRF(hydro,20,[],[],0.3,7);
hydro.plotDofs = [1,1;3,3;5,5;7,7;3,7;7,3];
writeBEMIOH5(hydro);
plotBEMIO(hydro);

if debugPlot ==1;
    % real part excitation
    figure; clf;
    for k=1:col
     subplot(1,col,k)
     plot(hydro.w,squeeze(hydro.ex_re(k,1,:)));
     ylabel('Re(Ex)')
     subplot(2,col,k)
     plot(hydro.w,squeeze(hydro.ex_im(k,1,:)));
     ylabel('Im(Ex)')
     xlabel('w (rad/s)')
    end
end

