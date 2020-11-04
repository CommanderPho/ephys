classdef Ripple
    %RIPPLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PeakTimes
        TimeStamps
        TimeIntervalCombined
        DetectorInfo
        SwMax
        RipMax
    end
    
    methods
        function obj = Ripple(ripple)
            %RIPPLE Construct an instance of this class
            %   Detailed explanation goes here
            obj.PeakTimes=ripple.peaktimes;
            obj.TimeStamps=ripple.timestamps;
            obj.DetectorInfo=ripple.detectorinfo;
            obj.SwMax=ripple.SwMax;
            obj.RipMax=ripple.RipMax;
        end
        
        function outputArg = plotScatter(obj)
            ticd=obj.TimeIntervalCombined;
            peaktimestamps=obj.PeakTimes*ticd.getSampleRate;
            peakTimeStampsAdjusted=ticd.adjustTimestampsAsIfNotInterrupted(peaktimestamps);
            peakTimesAdjusted=peakTimeStampsAdjusted/ticd.getSampleRate;
            peakripmax=obj.RipMax(:,1);
            s=scatter(hours(seconds(peakTimesAdjusted)),peakripmax...
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
        
        function ripples=getRipplesInAbsoluteTime(obj,toi)
            
            ticd=obj.TimeIntervalCombined;
            st=ticd.getStartTime;
            toi=datetime(st.Year,st.Month,st.Day)+toi;
            pt=seconds(obj.PeakTimes)+st;
            idx=pt>toi(1)&pt<toi(2);
            ripples=pt(idx);
            
        end
        
        function obj = setTimeIntervalCombined(obj,ticd)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.TimeIntervalCombined=ticd;
        end
    end
end

