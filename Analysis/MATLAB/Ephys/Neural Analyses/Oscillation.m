classdef (Abstract) Oscillation
    %OSCILLATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=protected)
        time
        voltageArray
        samplingRate
    end
    
    methods
        function obj = Oscillation(voltageArray, time)
            %OSCILLATION Construct an instance of this class
            %   Detailed explanation goes here
            obj.time=time;
            obj.voltageArray=voltageArray;
            period=unique(diff(time(2:100)));
            obj.samplingRate = round(max(1/period));
        end
        
        function timeFrequency = getTimeFrequencyMap(obj,...
                timeFrequencyMethod)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            timeFrequency=timeFrequencyMethod.execute(...
                obj.voltageArray, seconds(obj.time)+obj.getStartTime);
            
        end
        
        function p1=plot(obj,varargin)
            p1=plot(obj.time,obj.voltageArray,varargin{:});
            ax=gca;
            ax.XLim=[obj.time(1) obj.time(end)];
        end
        
        function obj=setTime(obj,time)
            obj.time=time;
        end
        function theChan=getDownSampled(obj,newRate)
            rate=obj.getSamplingRate/newRate;
            downsampledVA=downsample(obj.getVoltageArray,rate);
            downsampledtime=downsample(obj.getTime,rate);
            theChan=Channel(obj.getChannelName,downsampledVA,downsampledtime,...
                obj.getStartTime);
        end
        function ps=getPSpectrum(obj)
            tt1=timetable(seconds(obj.time),obj.voltageArray');
            [pxx,f] = pspectrum(tt1);
            ps=PowerSpectrum(pxx,f);
        end
        function obj=getWhitened_Obsolete(obj, fraquencyRange)
            Fs=obj.samplingRate;
            x=obj.voltageArray;
            x_detrended=detrend(x);
            if nargin>1
                x_whitened = whitening(x_detrended', Fs, 'freq', fraquencyRange);
            else
                x_whitened = whitening(x_detrended', Fs);
            end
            obj.voltageArray=x_whitened';
        end
        function obj=getWhitened(obj)            
            obj.voltageArray = WhitenSignal(obj.voltageArray,[],1);
        end
        function time=getTime(obj)            
            time = obj.time;
        end
        function newobj=getTimePoints(obj,timePoints)            
            newobj = obj;
            newobj.time=obj.time(timePoints);
            newobj.voltageArray=obj.voltageArray(timePoints);   
        end
        function obj=getLowpassFiltered(obj,filterFreq)            
            obj.voltageArray=ft_preproc_lowpassfilter(...
                obj.voltageArray,obj.samplingRate,filterFreq);
        end
        function obj=getHighpassFiltered(obj,filterFreqBand)            
            obj.voltageArray=ft_preproc_highpassfilter(...
                obj.voltageArray,obj.samplingRate,filterFreqBand,[],[],[]);
        end
        function time=getVoltageArray(obj)            
            time = obj.voltageArray;
        end
        function time=getSamplingRate(obj)            
            time = obj.samplingRate;
        end
        function obj=setSamplingRate(obj,newrate)            
            obj.samplingRate=newrate;
        end
     
        
    end
    
end

