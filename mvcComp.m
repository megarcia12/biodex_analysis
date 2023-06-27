% M3 Lab
% mvcComp.m
% Created 12 June 2023
% Mario Garcia | nfq3bd@virginia.edu
close all; clear; clc; warning off

%% File Location
pathName = 'C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Collected Data\Biodex\Biodex_Processed_Data\mMVC';
filePattern = fullfile(pathName, '*.mat');
matFiles = dir(filePattern); % Finds mat files that will be imported
bd = struct(); % Initialize the main structure
KeyPath = ('C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Collected Data\Biodex\Graph Functions'); % Input path were files are located
addpath(KeyPath);
for i = 1:length(matFiles) % Determines how many files will be imported
    matdata = load(fullfile(pathName, matFiles(i).name));
    tempName = matdata.mMVC;
    x = fieldnames(tempName);
    bd.(x{1}) = tempName;
end
subID = fieldnames(bd);
momDir = fieldnames(bd.(subID{1}).(subID{1}));
joint = struct(); % Initialize the joint structure
for j = 1:numel(momDir)
    ang = fieldnames(bd.(subID{1}).(subID{1}).(momDir{j}));
    for l = 1:numel(ang)
        joint.(momDir{j}).(ang{l}) = struct();
        for i = 1:numel(subID)
            joint.(momDir{j}).(ang{l}).(subID{i}) = bd.(subID{i}).(subID{i}).(momDir{j}).(ang{l});
        end
    end
end
clear filePattern matFiles pathName x ang i j l matdata tempName
l = 1;

% Iterate over each field in the main structure
for j = 1:numel(momDir)
    % Get the fieldnames of the sub-structure
    angles = fieldnames(bd.(subID{1}).(subID{1}).(momDir{j}));
    angles = sort(angles);
    % Iterate over each field in the sub-structure
    for k = 1:numel(angles)
        % Iterate over each field in the sub-sub-structure
        load('C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Collected Data\Biodex\Graph Functions\anthro.mat')
        anthro = rmfield(anthro,"M03");
        for z = 1:length(subID)
            norm(z) = anthro.(subID{z}).General.Mass;
        end
        sex = fieldnames(joint.(momDir{j}).(angles{k}));
        sex = string(sex);
        m = contains(sex,'M');
        f = contains(sex,'F');
        data = table2array(struct2table(joint.(momDir{j}).(angles{k})));
        data = data./norm;
        fData = data(f');
        mData = data(m');
        numInt = 5;
        intWidth = (max(data)-min(data))/numInt;
        x = min(data):intWidth:max(data);
        ncount = histc(data,x);
        relFreq = ncount/length(data);

%         %% Data Visualization
%         h = figure(l); % Creates figure - increases after each loop
%         h.WindowState = 'maximized'; % Fully opens windown to allow for better visuals when saving
%         subplot(3,2,1:2)
%         bar(x-intWidth/2,relFreq)
%         labels = arrayfun(@(value) num2str(value,'%.3f'),relFreq,'UniformOutput',false);
%         text(x-intWidth/2,relFreq,labels,...
%             'HorizontalAlignment','center',...
%             'VerticalAlignment','bottom')
%         xlabel('Torque (Nm)')
%         ylabel('Frequency (%)')
%         title('Relative Frequency')
% 
%         subplot(3,2,3)
%         distributionPlot(data','widthDiv',[2 1],'histOri','left','color',[27,158,119]/255,'showMM',4)
%         distributionPlot(gca,fData','widthDiv',[2 2],'histOri','right','color',[217,95,2]/255,'showMM',4)
%         ylabel('Torque (Nm)')
%         title('Total-Female Violin')
% 
%         subplot(3,2,4)
%         distributionPlot(data','widthDiv',[2 1],'histOri','left','color',[27,158,119]/255,'showMM',4)
%         distributionPlot(gca,mData','widthDiv',[2 2],'histOri','right','color',[117,112,179]/255,'showMM',4)
%         ylabel('Torque (Nm)')
%         title('Total-Male Violin')
% 
%         subplot(3,2,5)
%         distributionPlot(fData','widthDiv',[2 1],'histOri','left','color',[217,95,2]/255,'showMM',4)
%         distributionPlot(gca,mData','widthDiv',[2 2],'histOri','right','color',[117,112,179]/255,'showMM',4)
%         ylabel('Torque (Nm)')
%         title('Female-Male Violin')
% 
%         subplot(3,2,6)
%         boxchart(data')
%         hold on
%         swarmchart(ones(size(fData)),fData,[],[217,95,2]/255)
%         swarmchart(ones(size(mData)),mData,[],[117,112,179]/255)
%         hold off
%         title('Box Plot')
%         ylabel('Torque (Nm)')
%         text(2,mean(data(:)),num2str(mean(data(:))),...
%             'HorizontalAlignment','right',...
%             'VerticalAlignment','middle',...
%             'Color',[27,158,119]/255)
%         yline(mean(data(:)),'Color',[27,158,119]/255)
%         text(2,mean(mData(:)),num2str(mean(mData(:))),...
%             'HorizontalAlignment','right',...
%             'VerticalAlignment','bottom',...
%             'Color',[117,112,179]/255)
%         yline(mean(mData(:)),'Color',[117,112,179]/255)
%         text(2,mean(fData(:)),num2str(mean(fData(:))),...
%             'HorizontalAlignment','right',...
%             'VerticalAlignment','top',...
%             'Color',[217,95,2]/255)
%         yline(mean(fData(:)),'Color',[217,95,2]/255)
%         sgtitle([upper(extractBefore(momDir{j},'_')),' ',upper(extractAfter(momDir{j},'_')),' ',upper(angles{k})])
%         path = 'C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Collected Data\Biodex\Biodex_Processed_Data\Data Plots3';
%         saveas(h,fullfile(path,sprintf([upper(momDir{j}),'_',upper(angles{k})])),'png');
%         l = l+1;

        %% Data Values
        st.totalMax(k,j) = max(data); st.fMax(k,j) = max(fData); st.mMax(k,j) = max(mData);
        st.totalMean(k,j) = mean(data); st.fMean(k,j) = mean(fData); st.mMean(k,j) = mean(mData);
        st.totalStD(k,j) = std(data); st.fStD(k,j) = std(fData); st.mStD(k,j) = std(mData);
        st.totalRange(k,j) = max(data)-min(data); st.fRange(k,j) = max(fData)-min(fData); st.mRange(k,j) = max(mData)-min(mData);
        st.key(k,j) = string(angles{k});
    end
    st.key(5,j) = (momDir{j});
end
