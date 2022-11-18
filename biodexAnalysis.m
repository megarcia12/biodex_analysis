% M3 Lab
% biodexAnalysis.m
% Created 26 October 2022
% Updated 8 November 2022
% Mario Garcia | nfq3bd@virginia.edu & Emily McCain | ypj4nt@virginia.edu

close all; clear; clc;

%% File Location
PathName = uigetdir('.txt','Select the file you wish to analyize') ; % only looks for .txt files
% Get a list of all files in the folder with desired pattern
filePattern = fullfile(PathName, '**/*.txt') ;
Files = dir(filePattern) ;
Files = {Files.name}' ;

%% File splitting
fn=regexp(Files,'\w*(?=.txt)','match') ;
fname = [fn{:,:}]' ;

cng = regexp(fname,'_','split') ;
change = [cng{:,:}]' ;
num_subs_times_parameters = length(change) ;
change = reshape(change,[num_subs_times_parameters./length(Files),length(Files)]) ;

%% Assigns Information based on regular trial or iterative change
[m,~] = size(change) ;
if m == 3
    subject = change(1,:) ;
    joint = change(2,: );
    direc = change(3,:) ;
else
    iteration = change(1,:);
    subject = change(2,:) ;
    joint = change(3,: );
    direc = change(4,:) ;
end

for n=1:length(Files)
    trial{1,n} = [joint{1,n},'_',direc{1,n}] ;
end

%% Get the data from the files
for nfiles =1:length(Files)
    csub = (subject{1,nfiles}) ;
    cjoint = (joint{1,nfiles}) ;
    cdirection = (direc{1,nfiles}) ;
    [deMVC.(subject{1,nfiles}).(trial{1,nfiles}).rmvc,...
        deMVC.(subject{1,nfiles}).(trial{1,nfiles}).pmvc,...
        deMVC.(subject{1,nfiles}).(trial{1,nfiles}).amvc,...
        metadata.(subject{1,nfiles}).(trial{1,nfiles}).ind_metadata]= importBiodex([PathName,'\',Files{nfiles,1}]) ;
    
    %% Checks each trial against metadata to make sure there are no errors in naming
    csub = convertCharsToStrings(csub) ;
    cjoint = convertCharsToStrings(cjoint) ;
    cdirection = convertCharsToStrings(cdirection) ;
    
    j = metadata.(subject{1,nfiles}).(trial{1,nfiles}).ind_metadata.subject ;
    k =  metadata.(subject{1,nfiles}).(trial{1,nfiles}).ind_metadata.joint ;
    l =  metadata.(subject{1,nfiles}).(trial{1,nfiles}).ind_metadata.match ;
    
    if strcmpi(csub,j) ~= 1
        fprintf('Expected: %s_%s_%s\n', csub, cjoint, cdirection)
        fprintf('The metadata subject code %s does not match for %s_%s_%s.\n', j, csub, cjoint, cdirection)
        fprintf('The file is located in %s\n', PathName)
        if m ~=3
            citer = (iteration{1,nfiles}) ;
            citer = convertCharsToStrings(citer) ;
            fprintf('Using iteration code %s\n', citer)
        end
        break
    end
    
    if strcmpi(cjoint,k) ~= 1
        fprintf('The metadata subject joint %s does not match for %s_%s_%s.\n', k, csub, cjoint, cdirection)
        fprintf('The file is located in %s\n', PathName)
        if m ~=3
            citer = (iteration{1,nfiles}) ;
            citer = convertCharsToStrings(citer) ;
            fprintf('Using iteration code %s\n', citer)
        end
        break
    end
    
    if strcmpi(cdirection,l) ~= 1
        fprintf('The metadata subject direction %s does not match for %s_%s_%s.\n', l, csub, cjoint, cdirection)
        fprintf('The file is located in %s\n', PathName)
        if m ~=3
            citer = (iteration{1,nfiles}) ;
            citer = convertCharsToStrings(citer) ;
            fprintf('Using iteration code %s\n', citer)
        end
        break
    end
end

%% Var clearing
clear cdirection cjoint ctrial j k l nfiles
clear num_sub_times_parameters subject testingparameter trial
clear direc Files joint num_subs_times_parameters s filePattern


%% Save check
fprintf('Would you like to save this data?\n')
promt = input('Save -> [Y|N]\n','s') ;
exp = promt ;
if strcmpi(exp,'y')
    %% Folder Check/Creation
    dataFolder = uigetdir('D:\', 'Select Location you would like to save this data') ;
    location = fullfile(dataFolder, 'Biodex_Processed_Data');

    if ~exist(location, 'dir')
        mkdir(dataFolder,'Biodex_Processed_Data')
    end
    %% Var clearing
    clear n change fn fname cng m iteration exp promt
    clear PathName dataFolder
    csub = sprintf(csub);
    deMVC.dateModified = datetime;
    save(fullfile(location, csub))
    %% Var clearing
    clear location csub
else
    %% Var clearing
    clear n change fn fname cng m iteration
    clear location exp promt csub
end