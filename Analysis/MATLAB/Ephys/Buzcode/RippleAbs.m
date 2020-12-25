classdef RippleAbs
    %RIPPLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TimeIntervalCombined
        DetectorInfo
    end
    methods (Abstract)
        getPeakTimes(obj)
        getStartStopTimes(obj)
        getRipMax(obj)
    end
    methods

        
        function outputArg = plotScatterHoursInXAxes(obj)
            ticd=obj.TimeIntervalCombined;
            peaktimestamps=obj.PeakTimes*ticd.getSampleRate;
            peakTimeStampsAdjusted=ticd.adjustTimestampsAsIfNotInterrupted(peaktimestamps);
            peakTimesAdjusted=peakTimeStampsAdjusted/ticd.getSampleRate;
            peakripmax=obj.RipMax(:,1);
            s=scatter(hours(seconds(peakTimesAdjusted)),peakripmax...
                ,'Marker','.','MarkerFaceAlpha',.7,'MarkerEdgeAlpha',.7,...
                'SizeData',50);
            
        end
        function outputArg = plotScatterAbsoluteTimeInXAxes(obj)
            ticd=obj.TimeIntervalCombined;
            peaktimestamps=obj.PeakTimes*ticd.getSampleRate;
            peakTimeStampsAdjusted=ticd.adjustTimestampsAsIfNotInterrupted(peaktimestamps);
            peakTimesAdjusted=peakTimeStampsAdjusted/ticd.getSampleRate;
            peakripmax=obj.RipMax(:,1);
            s=scatter(seconds(peakTimesAdjusted)+ticd.getStartTime,peakripmax...
                ,'Marker','.','MarkerFaceAlpha',.7,'MarkerEdgeAlpha',.7,...
                'SizeData',50);
            
        end
        function [p2] = plotHistCount(obj, TimeBinsInSec)
            if ~exist('TimeBinsInSec','var')
                TimeBinsInSec=30;
            end
            ticd=obj.TimeIntervalCombined;
            peaktimestamps=obj.PeakTimes*ticd.getSampleRate;
            peakTimeStampsAdjusted=ticd.adjustTimestampsAsIfNotInterrupted(peaktimestamps);
            peakTimesAdjusted=peakTimeStampsAdjusted/ticd.getSampleRate;
            [N,edges]=histcounts(peakTimesAdjusted,1:TimeBinsInSec:max(peakTimesAdjusted));
            t=hours(seconds(edges(1:(numel(edges)-1))+15));
            t1=linspace(min(t),max(t),numel(t)*10);
            N=interp1(t,N,t1,'spline','extrap');
            p2=plot(t1,N,'LineWidth',1);
        end
        
        function [ripples, y]=getRipplesTimesInWindow(obj,toi)
            
            ticd=obj.TimeIntervalCombined;
            if isduration(toi)
                st=ticd.getStartTime;
                toi1=datetime(st.Year,st.Month,st.Day)+toi;
            else
                toi1=toi;
            end
            samples=ticd.getSampleFor(toi1);
            secs=samples/ticd.getSampleRate;
            peaktimes=obj.getPeakTimes;
            idx=peaktimes>=secs(1)&peaktimes<=secs(2);
            pt1=peaktimes(idx);
            ripmax=obj.getRipMax;
            y=ripmax(idx);
            if ~isempty(pt1)
                sample=pt1*ticd.getSampleRate;
                ripples=ticd.getRealTimeFor(sample);
            else
                ripples=[];
            end
            
        end
        function obj=getRipplesInWindow(obj,toi)
%             
%             ticd=obj.TimeIntervalCombined;
%             if isduration(toi)
%                 st=ticd.getStartTime;
%                 toi1=datetime(st.Year,st.Month,st.Day)+toi;
%             else
%                 toi1=toi;
%             end
%             samples=ticd.getSampleFor(toi1);
%             secs=samples/ticd.getSampleRate;
%             idx=obj.PeakTimes>=secs(1)&obj.PeakTimes<=secs(2);
%             ticd_new=obj.TimeIntervalCombined.getTimeIntervalForTimes(toi(1),toi(2));
%             dt=ticd_new.getStartTime-ticd.getStartTime;
% 
%             obj.PeakTimes=obj.PeakTimes(idx);
%             obj.PeakTimes-seconds(dt)
%             obj.RipMax=obj.RipMax(idx,:);
%             obj.SwMax=obj.SwMax(idx,:);
%             obj.TimeStamps=obj.TimeStamps(idx,:);
%             obj.TimeIntervalCombined
        end
        function []= saveEventsNeuroscope(obj,pathname)
            rippleFiles = dir(fullfile(pathname,'*.R*.evt'));
            if isempty(rippleFiles)
                fileN = 1;
            else
                %set file index to next available value\
                pat = '.R[0-9].';
                fileN = 0;
                for ii = 1:length(rippleFiles)
                    token  = regexp(rippleFiles(ii).name,pat);
                    val    = str2double(rippleFiles(ii).name(token+2:token+4));
                    fileN  = max([fileN val]);
                end
                fileN = fileN + 1;
            end
            tokens=tokenize(pathname,filesep);
            filename=tokens{end};
            fid = fopen(sprintf('%s%s%s.R%02d.evt',pathname,filesep,filename,fileN),'w');
            
            % convert detections to milliseconds
            peakTimes= obj.getPeakTimes*1000;
            startStopTimes= obj.getStartStopTimes*1000;
            fprintf(1,'Writing event file ...\n');
            for ii = 1:size(peakTimes,1)
                fprintf(fid,'%9.1f\tstart\n',startStopTimes(ii,1));
                fprintf(fid,'%9.1f\tpeak\n',peakTimes(ii));
                fprintf(fid,'%9.1f\tstop\n',startStopTimes(ii,2));
            end
            fclose(fid);
        end
        function obj = setTimeIntervalCombined(obj,ticd)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.TimeIntervalCombined=ticd;
        end
    end
end

