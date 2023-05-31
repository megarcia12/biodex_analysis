function [data,fdata,pmax,tmax,mmax,smax,metadata] = importBiodex(filename, dataLines)
%IMPORTFILE Import data from a text file
%% Input handling
opts = delimitedTextImportOptions("NumVariables", 8, "Encoding", "UTF-8");

% Specify range and delimiter
opts.DataLines = [2, 2];
opts.Delimiter = " ";

% Specify column names and types
opts.VariableNames = ["Var1", "Rep", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8"];
opts.SelectedVariableNames = "Rep";
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% Specify variable properties
opts = setvaropts(opts, ["Var1", "Rep", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Rep", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8"], "EmptyFieldRule", "auto");

% Import the data
csub = readmatrix(filename, opts);

% Clear temporary variables
clear opts

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [53, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 9, "Encoding", "UTF-8");

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = " ";

% Specify column names and types
opts.VariableNames = ["Set", "Rep", "mSec", "TORQUE", "POSITION", "POS_ANAT", "VELOCITY", "VarName8", "VarName9"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% Specify variable properties
opts = setvaropts(opts, "VarName9", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "VarName9", "EmptyFieldRule", "auto");
opts = setvaropts(opts, "Set", "TrimNonNumeric", true);
opts = setvaropts(opts, "Set", "ThousandsSeparator", ",");

%% Import the data
tbl = readtable(filename, opts);
ind.rep1 = ((tbl.Rep== 1)); % Finds Rep 1
ind.rep2 = ((tbl.Rep== 2)); % Finds Rep 2
angles = angleImport(filename); % Imports the angles for the joint
if length(angles) == 4
    for na = 1:length(angles)
        ind.(['a',num2str(angles(1,na))]) = (tbl.Set==na);
        cangle = (['a',num2str(angles(1,na))]); % Sets current angle
        for nReps = 1:2
            crep = ['rep',num2str(nReps)]; % Sets current rep
            itrial = (ind.(cangle)) & (ind.(crep)); % Creates the trial to be used by looking for the 
            data.(cangle).(crep) = [tbl.mSec(itrial),tbl.TORQUE(itrial)]; % Saves data for time and torque
            % Data Filter
            w_coff1 =20; w_samp = 100;
            [b1,a1] = butter(2,(w_coff1/(w_samp/2)),'low');
            fdata.(cangle).(crep)(:,2) = filtfilt(b1,a1,data.(cangle).(crep)(:,2));
            fdata.(cangle).(crep)(:,1) = data.(cangle).(crep)(:,1);
            if sum(fdata.(cangle).(crep)(:,2)) > 0 % Checks to see if the data is positive
                % Max Calculations
                [cmax.(cangle).(crep),s] = max(fdata.(cangle).(crep)(:,2));
                [c,~] = size(fdata.(cangle).(crep)(:,2));
                if s < 50
                    mdmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(1:100,2));
                else
                    mdmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(s-49:s+50,2));
                end
                if s > c-100
                    swmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(end-100:end,2));
                else
                    swmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(s:s+99,2));
                end
            elseif sum(fdata.(cangle).(crep)(:,2)) < 0 % Checks to see if the data is negative
                % Max Calculations
                [cmax.(cangle).(crep),s] = max(-fdata.(cangle).(crep)(:,2));
                [c,~] = size(fdata.(cangle).(crep)(:,2));
                if s < 50
                    mdmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(1:100,2));
                else
                    mdmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(s-49:s+50,2));
                end
                if s > c-100
                    swmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(end-100:end,2));
                else
                    swmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(s:s+99,2));
                end
            else % Takes care of any empty fields (lost data, excluded data, ect)
                cmax.(cangle).(crep) = 0; % Sets the empty field to 0 to avoid issues for max and average

            end
        end
        pmax.(cangle) = max(abs(cmax.(cangle).rep1),abs(cmax.(cangle).rep2));
        tmax.(cangle) = (cmax.(cangle).rep1+cmax.(cangle).rep2)/2; % Manual calculation of the max for each angle
        if pmax.(cangle) == cmax.(cangle).rep1
            mmax.(cangle) = mdmax.(cangle).rep1;
            smax.(cangle) = swmax.(cangle).rep1;
        else
            mmax.(cangle) = mdmax.(cangle).rep2;
            smax.(cangle) = swmax.(cangle).rep2;
        end
    end
else
    for na = 1:2:length(angles)
        ind.(['a',num2str(angles(1,na))]) = (tbl.Set==na);
        cangle = (['a',num2str(angles(1,na))]); % Sets current angle
        crep = ['rep',num2str(1)]; % Sets current rep
        itrial = (ind.(cangle)); % Creates the trial to be used
        data.(cangle).(crep) = [tbl.mSec(itrial),tbl.TORQUE(itrial)]; % Saves data for time and torque
        % Data Filter
        w_coff1 =20; w_samp = 100;
        [b1,a1] = butter(2,(w_coff1/(w_samp/2)),'low');
        fdata.(cangle).(crep)(:,2) = filtfilt(b1,a1,data.(cangle).(crep)(:,2));
        fdata.(cangle).(crep)(:,1) = data.(cangle).(crep)(:,1);
        if sum(fdata.(cangle).(crep)(:,2)) > 0 % Checks to see if the data is positive
            % Max Calculations
            [cmax.(cangle).(crep),s] = max(fdata.(cangle).(crep)(:,2));
            [c,~] = size(fdata.(cangle).(crep)(:,2));
            if s < 50
                mdmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(1:100,2));
            else
                mdmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(s-49:s+50,2));
            end
            if s > c-100
                swmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(end-100:end,2));
            else
                swmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(s:s+99,2));
            end
        elseif sum(fdata.(cangle).(crep)(:,2)) < 0 % Checks to see if the data is negative
            % Max Calculations
            [cmax.(cangle).(crep),s] = max(-fdata.(cangle).(crep)(:,2));
            [c,~] = size(fdata.(cangle).(crep)(:,2));
            if s < 50
                mdmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(1:100,2));
            else
                mdmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(s-49:s+50,2));
            end
            if s > c-100
                swmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(end-100:end,2));
            else
                swmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(s:s+99,2));
            end
        else % Takes care of any empty fields (lost data, excluded data, ect)
            cmax.(cangle).(crep) = 0; % Sets the empty field to 0 to avoid issues for max and average
        end
        for na = 2:2:length(angles)
            ind.(['a',num2str(angles(1,na))]) = (tbl.Set==na);
            cangle = (['a',num2str(angles(1,na))]); % Sets current angle
            crep = ['rep',num2str(2)]; % Sets current rep
            itrial = (ind.(cangle)); % Creates the trial to be used
            data.(cangle).(crep) = [tbl.mSec(itrial),tbl.TORQUE(itrial)]; % Saves data for time and torque
            % Data Filter
            w_coff1 =20; w_samp = 100;
            [b1,a1] = butter(2,(w_coff1/(w_samp/2)),'low');
            fdata.(cangle).(crep)(:,2) = filtfilt(b1,a1,data.(cangle).(crep)(:,2));
            fdata.(cangle).(crep)(:,1) = data.(cangle).(crep)(:,1);
            if sum(fdata.(cangle).(crep)(:,2)) > 0 % Checks to see if the data is positive
                % Max Calculations
                [cmax.(cangle).(crep),s] = max(fdata.(cangle).(crep)(:,2));
                [c,~] = size(fdata.(cangle).(crep)(:,2));
                if s < 50
                    mdmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(1:100,2));
                else
                    mdmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(s-49:s+50,2));
                end
                if s > c-100
                    swmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(end-100:end,2));
                else
                    swmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(s:s+99,2));
                end
            elseif sum(fdata.(cangle).(crep)(:,2)) < 0 % Checks to see if the data is negative
                % Max Calculations
                [cmax.(cangle).(crep),s] = max(-fdata.(cangle).(crep)(:,2));
                [c,~] = size(fdata.(cangle).(crep)(:,2));
                if s < 50
                    mdmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(1:100,2));
                else
                    mdmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(s-49:s+50,2));
                end
                if s > c-100
                    swmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(end-100:end,2));
                else
                    swmax.(cangle).(crep) = mean(-fdata.(cangle).(crep)(s:s+99,2));
                end
            else % Takes care of any empty fields (lost data, excluded data, ect)
                cmax.(cangle).(crep) = 0; % Sets the empty field to 0 to avoid issues for max and average
            end
        end

    end
    for na = 1:length(angles)
        cangle = (['a',num2str(angles(1,na))]); % Sets current angle
        pmax.(cangle) = max(abs(cmax.(cangle).rep1),abs(cmax.(cangle).rep2));
        tmax.(cangle) = (cmax.(cangle).rep1+cmax.(cangle).rep2)/2; % Manual calculation of the max for each angle
        if pmax.(cangle) == cmax.(cangle).rep1
            mmax.(cangle) = mdmax.(cangle).rep1;
            smax.(cangle) = swmax.(cangle).rep1;
        else
            mmax.(cangle) = mdmax.(cangle).rep2;
            smax.(cangle) = swmax.(cangle).rep2;
        end
    end
end


%% Sets up Meta Data Analysis
info = trialDataImport(filename);
metadata.subject = string(info(1)); % Subject ID
metadata.joint = string(info(19)); % Joint
metadata.dof = string(info(20)); % Biodex designation
metadata.bdirection  = string(info(22) ); % Direction of movement

if contains(metadata.joint,'Ankle')==1
    if contains(metadata.dof, 'Plantar') && contains(metadata.bdirection, 'TOWARDS')
        metadata.match = 'df'; % Assigns dorsiflexion based on biodex direction
    else
        metadata.match = 'pf'; % Assigns plantar flexion based on biodex direction
    end

elseif contains(metadata.joint,'Knee')==1
    if contains(metadata.dof, 'Extension') && contains(metadata.bdirection, 'TOWARDS')
        metadata.match = 'fx'; % Assigns flexion based on biodex direction
    else
        metadata.match = 'ex'; % Assigns extension based on biodex direction
    end

elseif  contains(metadata.joint,'Hip')==1
    if contains(metadata.dof, 'Extension') && contains(metadata.bdirection, 'TOWARDS')
        metadata.match = 'ex'; % Assigns extension based on biodex direction
    elseif contains(metadata.dof, 'Extension') && contains(metadata.bdirection, 'AWAY')
        metadata.match = 'fx'; % Assigns flexion based on biodex direction
    elseif contains(metadata.dof, 'Abduction') && contains(metadata.bdirection, 'TOWARDS')
        metadata.match = 'ad'; % Assigns adduction based on biodex direction
    else
        metadata.match = 'ab'; % Assigns abduction based on biodex direction
    end
end

end