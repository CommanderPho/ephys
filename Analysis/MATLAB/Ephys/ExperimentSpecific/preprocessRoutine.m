sf=SessionFactory;
sessions=sf.getSessions('AA',1);
% sess={'PRE','SD_NSD','TRACK','POST'};
% ses=sess{3};
for ises=1:numel(sessions)
    theses=sessions(ises);
    pr=Preprocess(theses);
    arts=pr.reCalculateArtifacts;
%     wind=theses.getBlock(ses);
%     wind=[wind.t1 wind.t2];
%     arts.plot();
    datalfp=pr.getDataForLFP;
%     sdd=datalfp.getStateDetectionData;
    ripples=datalfp.getRippleEvents;
    ripples.plot
    ss=sdd.getStateSeries;
%     pr.getDataForClustering
end
f=FigureFactory.instance;
f.save(ses)