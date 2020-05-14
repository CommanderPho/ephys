classdef (Abstract)OpenEphysRecord < Timelined
    %OPENEPHYSRECORD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        Data
        Timestamps
        Header
        FileLoaderMethod
        Events
        Probe
    end
    properties (Access = private)
    end
    methods
        function obj = OpenEphysRecord(filename)
            %OPENEPHYSRECORD Construct an instance of this class
            %   Detailed explanation goes here
            [filepath,name,ext]=fileparts(filename);
            switch ext
                case '.oebin'
                    fileLoaderMethod = FileLoaderBinary(filename);
                case '.openephys'
                    fileLoaderMethod = FileLoaderOpenEphys(filename);
                case '.lfp'
                    fileLoaderMethod = FileLoaderLFP(filename);
                otherwise
                    
            end
            obj.FileLoaderMethod=fileLoaderMethod;
            obj.Events=[];
        end
        %% Functions
        
        function channel=getChannel(obj,chan)
            D = obj.Data;
            dat = double(D.Data.mapped(chan,:));
            channel = Channel(num2str(chan),obj.getTimestampsInSeconds, dat);
        end
        
        function combined=getTimeWindow(obj, timeWindow)
            ts=obj.getTimestamps.time;
            if nargin<2
                timeWindow=[ts(1) ts(end)];
            end
            try
                timeWindowInSeconds=seconds(timeWindow - obj.getRecordStartTime);
            catch
                timeWindowInSeconds=timeWindow;
            end
            idx=(timeWindowInSeconds(1)<ts)&...
                (timeWindowInSeconds(2)>=ts);
            selectedTimePoints=ts(idx);
            tsc=tscollection(selectedTimePoints);
            tsc.TimeInfo.StartDate=obj.getRecordStartTime;
            D = obj.Data;
            dat = double(D.Data.mapped(:,idx));
            for ichan=1:numel(obj.getChannelNames)
                ts1=timeseries(dat(ichan,:),selectedTimePoints,'Name',obj.getChannelNames{ichan});
                ts1.TimeInfo.StartDate=obj.getRecordStartTime;
                tsc=tsc.addts(ts1);
            end
            combined=ChannelTimeData(tsc);
        end
        
        function newOpenEphysRecordsCombined = plus(obj,recordToAdd)
            newOpenEphysRecordsCombined=OpenEphysRecordsCombined(obj,recordToAdd);
        end
        
        
        %% PLOTS
        function display(obj)
            %% TODO
            % List recording time and propetrites
            % additionalrecording properties can be listed here.
            file=obj.Data.Filename;
            h=obj.Header;
            fprintf('%s\n   %d channels @ %d Hz\n',file,numel(h.getChannels),h.getSampleRate)
            
        end
    end
    
    %% File Interactions
    methods (Access=public)
        
    end
    
    %% GETTER and SETTERS
    methods (Access=public)
        
        function events = getEvents(obj)
            events=obj.Events;
        end
        function evttbl = getEventTable(obj)
            tsc=obj.getTimestamps;
            ts=tsc.IsActive;
            evts=ts.Events;
            evttbl=[];
            iievt=0;
            for ievt=1:numel(evts)
                iievt=iievt+1;
                evt=evts(ievt);
                dif1=datetime(evt.StartDate)-ts.TimeInfo.StartDate;
                try
                    evttbl(iievt,:)=[1, seconds(seconds(evt.Time)+dif1)];
                catch
                    warning('unknow key.')
                end
            end
        end
        function obj = addEvents(obj,evts)
            obj.Events=[obj.Events evts];
            try
                tsc=obj.getTimestamps;
                tsnames=tsc.gettimeseriesnames;
                if numel(tsnames)<1
                    ts=timeseries(true(numel(tsc.Time),1),tsc.Time,'Name','IsActive');
                    ts.TimeInfo.StartDate=tsc.TimeInfo.StartDate;
                else
                    ts= tsc.(tsnames{1});
                    tsc=tsc.removets(tsnames{1});
                end
                for ievent=1:numel(evts)
                    evt=evts(ievent);
                    evtTime=datetime(evt.StartDate)+seconds(evt.Time);
                    biggerThanBegin=evtTime>=(seconds(ts.Time(1))+ts.TimeInfo.StartDate);
                    smallerThanEnd=evtTime<=(seconds(ts.Time(end))+ts.TimeInfo.StartDate);
                    inThisRecord=biggerThanBegin&&smallerThanEnd;
                    if inThisRecord
                        ts=ts.addevent(evt);
                    else
%                         warning(['Event cannot be added ' evt.Name ' ' evt.getTimeStr{:}]);
                    end
                end
                tsc=tsc.addts(ts);
                obj=obj.setTimestamps(tsc);
            catch
            end
        end
        function ts = getTimeline(obj)
            ts=obj.getTimestamps;
            step=diff([ts.Time(1) ts.Time(end)])/numel(ts.Time);
            newtime=linspace(ts.Time(1),ts.Time(end),1000);
            ts=ts.resample(newtime);
            try
                ts=ts.addsample('Data',false,'Time',ts.Time(1)-step);
            catch
                ts=ts.IsActive;
                ts=ts.addsample('Data',false,'Time',ts.Time(1)-step);
            end
            ts=ts.addsample('Data',false,'Time',ts.Time(end)+step);
        end
        function data=getData(obj)
            data=obj.Data;
        end
        
        function file=getFile(obj)
            file=obj.Data.Filename;
        end
        
        function obj=setData(obj, Data)
            obj.Data=Data;
        end
        
        function time=getXMLSettings(obj)
            time=obj.Header.SettingsAtXMLFile;
        end
        
        function sampleRate=getSampleRate(obj)
            sampleRate=obj.Header.getSampleRate;
        end
        
        function obj=setSampleRate(obj,samplerate)
            hdr=obj.Header;
            obj.Header=hdr.setSampleRate(samplerate);
        end
        
        function st=getRecordStartTime(obj)
            ts=obj.Timestamps;
            st=ts.TimeInfo.StartDate;
        end
        function st=getRecordEndTime(obj)
            timeInfo=obj.Timestamps.TimeInfo;
            st=timeInfo.StartDate+seconds(timeInfo.end);
        end
        
        function ts=getTimestamps(obj)
            ts=obj.Timestamps;
        end
        
        function obj=setTimestamps(obj,timestamps)
            obj.Timestamps=timestamps;
        end
        
        function flm=getFileLoaderMethod(obj)
            flm=obj.FileLoaderMethod;
        end
        function h=getHeader(obj)
            h=obj.Header;
        end
        function obj=setHeader(obj,h)
            obj.Header=h;
        end
        
        function chans=getChannelNames(obj)
            hdr=obj.Header;
            chans=hdr.getChannels;
        end
        function ind=getChannelIndexes(obj,channels)
            tbl1=obj.getHeader.getChannelsTable;
            tbl=struct2table(tbl1);
            if iscellstr(channels)||isstring(channels)
                ind=ismember(tbl.channel_name,channels);
                ind=find(ind);
            elseif ischar(channels)
                try
                    ind=strfndw(tbl.channel_name,channels);
                catch
                    ind=ismember(tbl.channel_name,channels);
                    ind=find(ind);
                end
            else
                channums=(tbl.recorded_processor_index+1);
                ind=ismember(channums,channels);
                ind=find(ind);
            end
            
        end
        function obj=setProbe(obj,probe)
            obj.Probe=probe;
            fprintf('Probe added.\n\t%s\n',probe);
        end        
    end
    methods (Access=public)
        function obj=getDownSampled(obj, newRate, newFolder)
            currentRate=obj.getSampleRate;
            numberOfChannels=numel(obj.getChannelNames);
            currentFileName=obj.getFile;
            [~,name,~]=fileparts(currentFileName);
            start_end=string([obj.getRecordStartTime obj.getRecordEndTime],...
                'HH-mm-ss');
            name=[name '_' start_end{1} '_' start_end{2}];
            ext='.lfp';
            newFileName=fullfile(newFolder,...
                sprintf('%s_down-sampled-%d',name,newRate),...
                sprintf('%s_down-sampled-%d%s',name,newRate,ext));
            [path,name,~]=fileparts(newFileName);
            mkdir(path);
            headerFile=fullfile(path,[name '.header-and-timestamps.mat']);
            if ~exist(newFileName,'file')
                % preprocess it
                system(sprintf('process_resample -f %d,%d -n %d %s %s',...
                    currentRate, newRate, numberOfChannels,...
                    currentFileName, newFileName));
            end
            
            if ~exist(headerFile,'file')
                sampleRateRatio = obj.getSampleRate/newRate;
                
                ts=obj.getTimestamps;
                ts_downsampled=double(downsample(ts.Time, sampleRateRatio));
                tsc_down=tscollection(ts_downsampled);
                tsc_down.TimeInfo.StartDate=ts.TimeInfo.StartDate;
                tsc_down.TimeInfo.Format=ts.TimeInfo.Format;
                obj=obj.setTimestamps(tsc_down);
                obj=obj.setSampleRate(newRate);
                header=obj.getHeader;
                timestamps=obj.getTimestamps;
                save(headerFile,'header','timestamps','-v7.3');
            end
            obj=OpenEphysRecordFactory.getOpenEphysRecord(newFileName);
        end
    end
    
    
    methods (Access=private)
        
    end
end