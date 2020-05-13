classdef Channel < Oscillation
    %CHANNEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=private)
        ChannelName
        StartTime
    end
    
    methods
        function obj = Channel(channelname,voltageArray,time,startTime)
            %CHANNEL Construct an instance of this class
            %   Detailed explanation goes here
        obj@Oscillation(voltageArray, time);
        obj.ChannelName=channelname;
        obj.StartTime=startTime;
        fprintf(...
            'New Channel %s, lenght %d, begin:end  %.0fs:%.0fs, %dHz, %15s\n',...
            obj.ChannelName,numel(obj.getVoltageArray),time(1),time(end),...
            obj.getSamplingRate,datestr(obj.getStartTime))
        end
        function obj=setStartTime(obj,startTime)
            obj.StartTime=startTime;
        end
        function chan=getChannelName(obj)
            chan=obj.ChannelName;
        end
        function chan=getChannelNumber(obj)
            chan=str2double(obj.ChannelName(3:end));
        end
        function st=getStartTime(obj)
            st=obj.StartTime;
        end
        function ts=getTimeSeries(obj)
            ts=timeseries(obj.getVoltageArray,obj.getTime);
            ts.TimeInfo.StartDate=obj.getStartTime;  
            ts.TimeInfo.Format=TimeFactory.getHHMMSS;
        end
    end
end

