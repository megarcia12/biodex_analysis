function [data,cmax,tmax,metadata] = importBiodex(filename, dataLines)
%IMPORTFILE Import data from a text file
%  [SET, REP, MSEC, TORQUE, POSITION, POS_ANAT, VELOCITY] =
%  IMPORTFILE(FILENAME) reads data from text file FILENAME for the
%  default selection.  Returns the data as column vectors.
%
%  [SET, REP, MSEC, TORQUE, POSITION, POS_ANAT, VELOCITY] =
%  IMPORTFILE(FILE, DATALINES) reads data for the specified row
%  interval(s) of text file FILENAME. Specify DATALINES as a positive
%  scalar integer or a N-by-2 array of positive scalar integers for
%  dis-contiguous row intervals.
%
%  Example:
%  [Set, Rep, mSec, TORQUE, POSITION, POS_ANAT, VELOCITY] = importfile("C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Biodex\Biodex Data\9_9_2022\Knee_calf.txt", [53, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 19-Sep-2022 10:51:01

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [53, Inf] ;
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 8, "Encoding", "UTF-8") ;

% Specify range and delimiter
opts.DataLines = dataLines ;
opts.Delimiter = " " ;

% Specify column names and types
opts.VariableNames = ["Set", "Rep", "mSec", "TORQUE", "POSITION", "POS_ANAT", "VELOCITY", "Var8"] ;
opts.SelectedVariableNames = ["Set", "Rep", "mSec", "TORQUE", "POSITION", "POS_ANAT", "VELOCITY"] ;
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "string"] ;

% Specify file level properties
opts.ExtraColumnsRule = "ignore" ;
opts.EmptyLineRule = "read" ;
opts.ConsecutiveDelimitersRule = "join" ;
opts.LeadingDelimitersRule = "ignore" ;

% Specify variable properties
opts = setvaropts(opts, "Var8", "WhitespaceRule", "preserve") ;
opts = setvaropts(opts, "Var8", "EmptyFieldRule", "auto") ;
opts = setvaropts(opts, "Set", "TrimNonNumeric", true) ;
opts = setvaropts(opts, "Set", "ThousandsSeparator", ",") ;

%% Import the data
tbl = readtable(filename, opts) ;
ind.rep1 = ((tbl.Rep== 1)) ; % Finds Rep 1
ind.rep2 = ((tbl.Rep== 2)) ; % Finds Rep 2
angles = angleImport(filename) ; % Imports the angles for the joint
for na = 1:length(angles)
    ind.(['a',num2str(angles(1,na))]) = (tbl.Set==na) ;
    cangle = (['a',num2str(angles(1,na))]) ; % Sets current angle
    
    for nReps = 1:2
        crep = ['rep',num2str(nReps)] ; % Sets current rep
        itrial = (ind.(cangle)) & (ind.(crep)) ; % Creates the trial to be used
        data.(cangle).(crep) = [tbl.mSec(itrial),tbl.TORQUE(itrial)] ; % Saves data for time and torque
        if sum(data.(cangle).(crep)(:,2)) > 0 % Checks to see if the data is positive
            [cmax.(cangle).(crep),~] = max(data.(cangle).(crep)(:,2)) ;
        elseif sum(data.(cangle).(crep)(:,2)) < 0 % Checks to see if the data is negative
            [cmax.(cangle).(crep),~] = max(-data.(cangle).(crep)(:,2)) ;
            cmax.(cangle).(crep) = -cmax.(cangle).(crep); % Changes the value back to a negative after finding max 
        else % Takes care of any empty fields (lost data, excluded data, ect)
            cmax.(cangle).(crep) = 0; % Sets the empty field to 0 to avoid issues for max and average
        end
    end

    tmax.(cangle) = (cmax.(cangle).rep1+cmax.(cangle).rep2)/2;
end

%% Sets up Meta Data Analysis
info = trialDataImport(filename) ;
metadata.subject = string(info(1)) ; % Subject ID
metadata.joint = string(info(19)) ; % Joint
metadata.dof = string(info(20)) ; % Biodex designation
metadata.bdirection  = string(info(22) ); % Direction of movement

if contains(metadata.joint,'Ankle')==1
    if contains(metadata.dof, 'Plantar') && contains(metadata.bdirection, 'TOWARDS') 
        metadata.match = 'dors' ; % Assigns dorsiflexion based on biodex direction
    else 
        metadata.match = 'plnt' ; % Assigns plantar flexion based on biodex direction
    end
    
elseif contains(metadata.joint,'Knee')==1
    if contains(metadata.dof, 'Extension') && contains(metadata.bdirection, 'TOWARDS')
        metadata.match = 'flx' ; % Assigns flexion based on biodex direction
    else 
        metadata.match = 'ext' ; % Assigns extension based on biodex direction
    end
    
elseif  contains(metadata.joint,'Hip')==1
    if contains(metadata.dof, 'Extension') && contains(metadata.bdirection, 'TOWARDS')
        metadata.match = 'ext' ; % Assigns extension based on biodex direction
    elseif contains(metadata.dof, 'Extension') && contains(metadata.bdirection, 'AWAY')
        metadata.match = 'flx' ; % Assigns flexion based on biodex direction
    elseif contains(metadata.dof, 'Abduction') && contains(metadata.bdirection, 'TOWARDS')
        metadata.match = 'ad' ; % Assigns adduction based on biodex direction
    else 
        metadata.match = 'ab' ; % Assigns abduction based on biodex direction
    end
end

end
