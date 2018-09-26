addpath(genpath('/home/perdikis/Desktop/cnbi_smrtrain/'))
lap = load('laplacian16.mat');
lap = lap.lap;

Path = '/mnt/cnbiserver/cnbi-commun/data/raw/inbox/Magdeburg_stroke/';
%SavePath = '/home/scratch/sperdikis/Git/cnbi-stroke-protocol/extra/fesprotocolextra/scripts/matlab/playback/';
SavePath = '~/Git/cnbi-stroke-protocol/extra/fesprotocolextra/scripts/matlab/playback/';

SubDir = dir(Path);
SubDir = SubDir(3:end);
isd = [SubDir(:).isdir];
SubDir = SubDir(isd);

for subject = 1:length(SubDir)
    Sub = SubDir(subject).name;
    SubSes = dir([Path '/' Sub]);
    SubSes = SubSes(3:end);
    isd = [SubSes(:).isdir];
    SubSes = SubSes(isd);
    
    onses = 0;
    for ses=1:length(SubSes)
        % Check if it is an online session
        SesName = SubSes(ses).name;
        
        if( strcmp(SesName(1:5),[Sub '.']) && (mean(isstrprop(SesName(6:end),'digit'))==1))
            onses = onses + 1;
            
            % Load log file
            LogFile = dir([Path '/' Sub '/' SesName '/*.log']);
            if(~isempty(LogFile))
                LogFile = LogFile.name;
                fid = fopen([Path '/' Sub '/' SesName '/' LogFile]);
                
                run=0;
                while(true)
                    run = run+1;    
                    % Read log line
                    Line = fgetl(fid);
                    if(Line == -1)
                        break;
                    end
                    
                    GDFName = Line(strfind(Line, SesName):strfind(Line, 'gdf')+2);
                    MATname = Line(strfind(Line, [Sub '_']):strfind(Line, 'mat')+2);
                    GDFPath = [Path '/' Sub '/' SesName '/' GDFName];
                    MATPath = [Path '/' Sub '/' MATname];
                    
                    [Acc probdata] = analyzeOnlineStroke(GDFPath,MATPath, lap);
                    
                    disp(['Subject: ' Sub ' , Session: ' num2str(onses) ' , Run: ' num2str(run) ' , Acc: ' num2str(round(Acc))]);
                    
                    if(~isnan(Acc))
                        % Save playback probability file
                        save([SavePath 'PB_' num2str(round(Acc)) '_' datestr(now,'yyyymmddHHMMSS')  '.mat'],'probdata');
                    end
                end
                
                fclose(fid);
                
            end
        end
    end
    

end