% M3 Lab
% lrComp.m
% Created 27 July 2023
% Mario Garcia | nfq3bd@virginia.edu
close all; clear; clc;

%% Required Value Import
run('mvcComp.m'); run('importVolume.m'); run('quintileAssign.m'); 
excludedSubjects = {'F07', 'M13'};
vol = rmfield(vol, excludedSubjects);

%% Sex Designation
id = fieldnames(vol);
m = contains(id, 'M');
f = contains(id, 'F');

%% Space Preallocation
numSubjects = numel(id);
t_equation_R{:,:} = ones(28, numSubjects);
t_R2_R = ones(28, numSubjects);
t_RMSE_R = ones(28, numSubjects); % Pre-allocate for raw torques with individual moment directions

%% Calculations
for i = 1:28
    %% Ankle Dorsiflexion
    if i <= 4
        for j = 1:length(id)
            AD.v(1,j) = vol.(id{j}).Ankle(2,2); % Extract dorsiflexion volume
        end

        for k = 1 % All ankle vol, all contractile, dorsiflexors, contractile dorsiflexors
            % Contractile means that I have taken away the fat infiltration
            % from the volume

            % Extract relevant data for regression
            adVolume = table2array(AD.v(k,:));
            rawTorque = data.Raw(i,:);
            mAdVolume = nonzeros(m.*adVolume)';
            mRawTorque = nonzeros(m.*rawTorque)';
            fAdVolume = nonzeros(f.*adVolume)';
            fRawTorque = nonzeros(f.*rawTorque)';

            %% Raw Torque Linear Regressions
            [t_equation_R{i,k}, t_R2_R(i,k), t_RMSE_R(i,k)] = linear_regression(adVolume, rawTorque);
            [m_equation_R{i,k}, m_R2_R(i,k), m_RMSE_R(i,k)] = linear_regression(mAdVolume, mRawTorque);
            [f_equation_R{i,k}, f_R2_R(i,k), f_RMSE_R(i,k)] = linear_regression(fAdVolume, fRawTorque);

            %% Limb Corrected Regression
            [t_equation_C{i,k}, t_R2_C(i,k), t_RMSE_C(i,k)] = linear_regression(adVolume, data.Corrected(i,:));
            [m_equation_C{i,k}, m_R2_C(i,k), m_RMSE_C(i,k)] = linear_regression(mAdVolume, nonzeros(m.*data.Corrected(i,:))');
            [f_equation_C{i,k}, f_R2_C(i,k), f_RMSE_C(i,k)] = linear_regression(fAdVolume, nonzeros(f.*data.Corrected(i,:))');

            %% Mass Normalized Regression
            [t_equation_M{i,k}, t_R2_M(i,k), t_RMSE_M(i,k)] = linear_regression(adVolume, data.MNorm(i,:));
            [m_equation_M{i,k}, m_R2_M(i,k), m_RMSE_M(i,k)] = linear_regression(mAdVolume, nonzeros(m.*data.MNorm(i,:))');
            [f_equation_M{i,k}, f_R2_M(i,k), f_RMSE_M(i,k)] = linear_regression(fAdVolume, nonzeros(f.*data.MNorm(i,:))');

            %% Height Mass Normalized Regression
            [t_equation_HM{i,k}, t_R2_HM(i,k), t_RMSE_HM(i,k)] = linear_regression(adVolume, data.HMNorm(i,:));
            [m_equation_HM{i,k}, m_R2_HM(i,k), m_RMSE_HM(i,k)] = linear_regression(mAdVolume, nonzeros(m.*data.HMNorm(i,:))');
            [f_equation_HM{i,k}, f_R2_HM(i,k), f_RMSE_HM(i,k)] = linear_regression(fAdVolume, nonzeros(f.*data.HMNorm(i,:))');
        end

        %% Ankle Plantarflexion
    elseif i>=5 && i<=8
        for j = 1:length(id)
            %             AP.v(1,j) = vol.(id{j}).Ankle(1,2); AP.v(2,j) = vol.(id{j}).Ankle(1,4);
            AP.v(1,j) = vol.(id{j}).Ankle(3,2); % AP.v(4,j) = vol.(id{j}).Ankle(3,4);
        end
        for k = 1; % All ankle vol, all contractile, dorsiflexors, contractile dorsiflexors
            % Contractile means that I have taken away the fat inflitration
            % from the volume
            %% Raw Torque Linear Regressions
            [eq,r,rm] = linear_regression(table2array(AP.v(k,:)),data.Raw(i,:)); % Linear regression for all subjects
            t_equation_R{i,k} = eq; t_R2_R(i,k) = r; t_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(AP.v(k,:)))',nonzeros(m.*data.Raw(i,:))'); % Linear regression for males
            m_equation_R{i,k} = eq; m_R2_R(i,k) = r; m_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(AP.v(k,:)))',nonzeros(f.*data.Raw(i,:))'); % Linear regression for females
            f_equation_R{i,k} = eq; f_R2_R(i,k) = r; f_RMSE_R(i,k) = rm;
            %% Limb Corrected Regression
            [eq,r,rm] = linear_regression(table2array(AP.v(k,:)),data.Corrected(i,:));
            t_equation_C{i,k} = eq; t_R2_C(i,k) = r; t_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(AP.v(k,:)))',nonzeros(m.*data.Corrected(i,:))');
            m_equation_C{i,k} = eq; m_R2_C(i,k) = r; m_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(AP.v(k,:)))',nonzeros(f.*data.Corrected(i,:))');
            f_equation_C{i,k} = eq; f_R2_C(i,k) = r; f_RMSE_C(i,k) = rm;
            %% Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(AP.v(k,:)),data.MNorm(i,:));
            t_equation_M{i,k} = eq; t_R2_M(i,k) = r; t_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(AP.v(k,:)))',nonzeros(m.*data.MNorm(i,:))');
            m_equation_M{i,k} = eq; m_R2_M(i,k) = r; m_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(AP.v(k,:)))',nonzeros(f.*data.MNorm(i,:))');
            f_equation_M{i,k} = eq; f_R2_M(i,k) = r; f_RMSE_M(i,k) = rm;
            %% Height Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(AP.v(k,:)),data.HMNorm(i,:));
            t_equation_HM{i,k} = eq; t_R2_HM(i,k) = r; t_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(AP.v(k,:)))',nonzeros(m.*data.HMNorm(i,:))');
            m_equation_HM{i,k} = eq; m_R2_HM(i,k) = r; m_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(AP.v(k,:)))',nonzeros(f.*data.HMNorm(i,:))');
            f_equation_HM{i,k} = eq; f_R2_HM(i,k) = r; f_RMSE_HM(i,k) = rm;

        end
        %% Hip Abduction
    elseif i>=9 && i<=11
        for j = 1:length(id)
            %             HB.v(1,j) = vol.(id{j}).Hip(1,2); HB.v(2,j) = vol.(id{j}).Hip(1,4);
            HB.v(1,j) = vol.(id{j}).Hip(4,2); % HB.v(4,j) = vol.(id{j}).Hip(4,4);
        end
        for k = 1;
            %% Raw Torque Linear Regressions
            [eq,r,rm] = linear_regression(table2array(HB.v(k,:)),data.Raw(i,:)); % Linear regression for all subjects
            t_equation_R{i,k} = eq; t_R2_R(i,k) = r; t_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HB.v(k,:)))',nonzeros(m.*data.Raw(i,:))'); % Linear regression for males
            m_equation_R{i,k} = eq; m_R2_R(i,k) = r; m_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HB.v(k,:)))',nonzeros(f.*data.Raw(i,:))'); % Linear regression for females
            f_equation_R{i,k} = eq; f_R2_R(i,k) = r; f_RMSE_R(i,k) = rm;
            %% Limb Corrected Regression
            [eq,r,rm] = linear_regression(table2array(HB.v(k,:)),data.Corrected(i,:));
            t_equation_C{i,k} = eq; t_R2_C(i,k) = r; t_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HB.v(k,:)))',nonzeros(m.*data.Corrected(i,:))');
            m_equation_C{i,k} = eq; m_R2_C(i,k) = r; m_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HB.v(k,:)))',nonzeros(f.*data.Corrected(i,:))');
            f_equation_C{i,k} = eq; f_R2_C(i,k) = r; f_RMSE_C(i,k) = rm;
            %% Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(HB.v(k,:)),data.MNorm(i,:));
            t_equation_M{i,k} = eq; t_R2_M(i,k) = r; t_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HB.v(k,:)))',nonzeros(m.*data.MNorm(i,:))');
            m_equation_M{i,k} = eq; m_R2_M(i,k) = r; m_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HB.v(k,:)))',nonzeros(f.*data.MNorm(i,:))');
            f_equation_M{i,k} = eq; f_R2_M(i,k) = r; f_RMSE_M(i,k) = rm;
            %% Height Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(HB.v(k,:)),data.HMNorm(i,:));
            t_equation_HM{i,k} = eq; t_R2_HM(i,k) = r; t_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HB.v(k,:)))',nonzeros(m.*data.HMNorm(i,:))');
            m_equation_HM{i,k} = eq; m_R2_HM(i,k) = r; m_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HB.v(k,:)))',nonzeros(f.*data.HMNorm(i,:))');
            f_equation_HM{i,k} = eq; f_R2_HM(i,k) = r; f_RMSE_HM(i,k) = rm;

        end
        %% Hip Adduction
    elseif i>=12 && i<=14
        for j = 1:length(id)
            %             HD.v(1,j) = vol.(id{j}).Hip(1,2); HD.v(2,j) = vol.(id{j}).Hip(1,4);
            HD.v(1,j) =  vol.(id{j}).Hip(5,2); % HD.v(4,j) = vol.(id{j}).Hip(5,4);
        end
        for k = 1;
            %% Raw Torque Linear Regressions
            [eq,r,rm] = linear_regression(table2array(HD.v(k,:)),data.Raw(i,:)); % Linear regression for all subjects
            t_equation_R{i,k} = eq; t_R2_R(i,k) = r; t_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HD.v(k,:)))',nonzeros(m.*data.Raw(i,:))'); % Linear regression for males
            m_equation_R{i,k} = eq; m_R2_R(i,k) = r; m_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HD.v(k,:)))',nonzeros(f.*data.Raw(i,:))'); % Linear regression for females
            f_equation_R{i,k} = eq; f_R2_R(i,k) = r; f_RMSE_R(i,k) = rm;
            %% Limb Corrected Regression
            [eq,r,rm] = linear_regression(table2array(HD.v(k,:)),data.Corrected(i,:));
            t_equation_C{i,k} = eq; t_R2_C(i,k) = r; t_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HD.v(k,:)))',nonzeros(m.*data.Corrected(i,:))');
            m_equation_C{i,k} = eq; m_R2_C(i,k) = r; m_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HD.v(k,:)))',nonzeros(f.*data.Corrected(i,:))');
            f_equation_C{i,k} = eq; f_R2_C(i,k) = r; f_RMSE_C(i,k) = rm;
            %% Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(HD.v(k,:)),data.MNorm(i,:));
            t_equation_M{i,k} = eq; t_R2_M(i,k) = r; t_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HD.v(k,:)))',nonzeros(m.*data.MNorm(i,:))');
            m_equation_M{i,k} = eq; m_R2_M(i,k) = r; m_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HD.v(k,:)))',nonzeros(f.*data.MNorm(i,:))');
            f_equation_M{i,k} = eq; f_R2_M(i,k) = r; f_RMSE_M(i,k) = rm;
            %% Height Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(HD.v(k,:)),data.HMNorm(i,:));
            t_equation_HM{i,k} = eq; t_R2_HM(i,k) = r; t_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HD.v(k,:)))',nonzeros(m.*data.HMNorm(i,:))');
            m_equation_HM{i,k} = eq; m_R2_HM(i,k) = r; m_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HD.v(k,:)))',nonzeros(f.*data.HMNorm(i,:))');
            f_equation_HM{i,k} = eq; f_R2_HM(i,k) = r; f_RMSE_HM(i,k) = rm;

        end
        %% Hip Extension
    elseif i>=15 && i<=17
        for j = 1:length(id)
            %             HE.v(1,j) = vol.(id{j}).Hip(1,2); HE.v(2,j) = vol.(id{j}).Hip(1,4);
            HE.v(1,j) = vol.(id{j}).Hip(3,2); % HE.v(4,j) = vol.(id{j}).Hip(3,4);
        end
        for k = 1;
            %% Raw Torque Linear Regressions
            [eq,r,rm] = linear_regression(table2array(HE.v(k,:)),data.Raw(i,:)); % Linear regression for all subjects
            t_equation_R{i,k} = eq; t_R2_R(i,k) = r; t_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HE.v(k,:)))',nonzeros(m.*data.Raw(i,:))'); % Linear regression for males
            m_equation_R{i,k} = eq; m_R2_R(i,k) = r; m_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HE.v(k,:)))',nonzeros(f.*data.Raw(i,:))'); % Linear regression for females
            f_equation_R{i,k} = eq; f_R2_R(i,k) = r; f_RMSE_R(i,k) = rm;
            %% Limb Corrected Regression
            [eq,r,rm] = linear_regression(table2array(HE.v(k,:)),data.Corrected(i,:));
            t_equation_C{i,k} = eq; t_R2_C(i,k) = r; t_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HE.v(k,:)))',nonzeros(m.*data.Corrected(i,:))');
            m_equation_C{i,k} = eq; m_R2_C(i,k) = r; m_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HE.v(k,:)))',nonzeros(f.*data.Corrected(i,:))');
            f_equation_C{i,k} = eq; f_R2_C(i,k) = r; f_RMSE_C(i,k) = rm;
            %% Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(HE.v(k,:)),data.MNorm(i,:));
            t_equation_M{i,k} = eq; t_R2_M(i,k) = r; t_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HE.v(k,:)))',nonzeros(m.*data.MNorm(i,:))');
            m_equation_M{i,k} = eq; m_R2_M(i,k) = r; m_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HE.v(k,:)))',nonzeros(f.*data.MNorm(i,:))');
            f_equation_M{i,k} = eq; f_R2_M(i,k) = r; f_RMSE_M(i,k) = rm;
            %% Height Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(HE.v(k,:)),data.HMNorm(i,:));
            t_equation_HM{i,k} = eq; t_R2_HM(i,k) = r; t_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HE.v(k,:)))',nonzeros(m.*data.HMNorm(i,:))');
            m_equation_HM{i,k} = eq; m_R2_HM(i,k) = r; m_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HE.v(k,:)))',nonzeros(f.*data.HMNorm(i,:))');
            f_equation_HM{i,k} = eq; f_R2_HM(i,k) = r; f_RMSE_HM(i,k) = rm;

        end
        %% Hip Flexion
    elseif i>=18 && i<=20
        for j = 1:length(id)
            %             HF.v(1,j) = vol.(id{j}).Hip(1,2); HF.v(2,j) = vol.(id{j}).Hip(1,4);
            HF.v(1,j) = vol.(id{j}).Hip(2,2); % HF.v(4,j) = vol.(id{j}).Hip(2,4);
        end
        for k = 1;
            %% Raw Torque Linear Regressions
            [eq,r,rm] = linear_regression(table2array(HF.v(k,:)),data.Raw(i,:)); % Linear regression for all subjects
            t_equation_R{i,k} = eq; t_R2_R(i,k) = r; t_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HF.v(k,:)))',nonzeros(m.*data.Raw(i,:))'); % Linear regression for males
            m_equation_R{i,k} = eq; m_R2_R(i,k) = r; m_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HF.v(k,:)))',nonzeros(f.*data.Raw(i,:))'); % Linear regression for females
            f_equation_R{i,k} = eq; f_R2_R(i,k) = r; f_RMSE_R(i,k) = rm;
            %% Limb Corrected Regression
            [eq,r,rm] = linear_regression(table2array(HF.v(k,:)),data.Corrected(i,:));
            t_equation_C{i,k} = eq; t_R2_C(i,k) = r; t_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HF.v(k,:)))',nonzeros(m.*data.Corrected(i,:))');
            m_equation_C{i,k} = eq; m_R2_C(i,k) = r; m_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HF.v(k,:)))',nonzeros(f.*data.Corrected(i,:))');
            f_equation_C{i,k} = eq; f_R2_C(i,k) = r; f_RMSE_C(i,k) = rm;
            %% Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(HF.v(k,:)),data.MNorm(i,:));
            t_equation_M{i,k} = eq; t_R2_M(i,k) = r; t_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HF.v(k,:)))',nonzeros(m.*data.MNorm(i,:))');
            m_equation_M{i,k} = eq; m_R2_M(i,k) = r; m_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HF.v(k,:)))',nonzeros(f.*data.MNorm(i,:))');
            f_equation_M{i,k} = eq; f_R2_M(i,k) = r; f_RMSE_M(i,k) = rm;
            %% Height Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(HF.v(k,:)),data.HMNorm(i,:));
            t_equation_HM{i,k} = eq; t_R2_HM(i,k) = r; t_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(HF.v(k,:)))',nonzeros(m.*data.HMNorm(i,:))');
            m_equation_HM{i,k} = eq; m_R2_HM(i,k) = r; m_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(HF.v(k,:)))',nonzeros(f.*data.HMNorm(i,:))');
            f_equation_HM{i,k} = eq; f_R2_HM(i,k) = r; f_RMSE_HM(i,k) = rm;

        end
        %% Knee Extension
    elseif i>=21 && i<=24
        for j = 1:length(id)
            %             KE.v(1,j) = vol.(id{j}).Knee(1,2); KE.v(2,j) = vol.(id{j}).Knee(1,4);
            KE.v(1,j) = vol.(id{j}).Knee(3,2); % KE.v(4,j) = vol.(id{j}).Knee(3,4);
        end
        for k = 1;
            %% Raw Torque Linear Regressions
            [eq,r,rm] = linear_regression(table2array(KE.v(k,:)),data.Raw(i,:)); % Linear regression for all subjects
            t_equation_R{i,k} = eq; t_R2_R(i,k) = r; t_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(KE.v(k,:)))',nonzeros(m.*data.Raw(i,:))'); % Linear regression for males
            m_equation_R{i,k} = eq; m_R2_R(i,k) = r; m_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(KE.v(k,:)))',nonzeros(f.*data.Raw(i,:))'); % Linear regression for females
            f_equation_R{i,k} = eq; f_R2_R(i,k) = r; f_RMSE_R(i,k) = rm;
            %% Limb Corrected Regression
            [eq,r,rm] = linear_regression(table2array(KE.v(k,:)),data.Corrected(i,:));
            t_equation_C{i,k} = eq; t_R2_C(i,k) = r; t_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(KE.v(k,:)))',nonzeros(m.*data.Corrected(i,:))');
            m_equation_C{i,k} = eq; m_R2_C(i,k) = r; m_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(KE.v(k,:)))',nonzeros(f.*data.Corrected(i,:))');
            f_equation_C{i,k} = eq; f_R2_C(i,k) = r; f_RMSE_C(i,k) = rm;
            %% Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(KE.v(k,:)),data.MNorm(i,:));
            t_equation_M{i,k} = eq; t_R2_M(i,k) = r; t_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(KE.v(k,:)))',nonzeros(m.*data.MNorm(i,:))');
            m_equation_M{i,k} = eq; m_R2_M(i,k) = r; m_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(KE.v(k,:)))',nonzeros(f.*data.MNorm(i,:))');
            f_equation_M{i,k} = eq; f_R2_M(i,k) = r; f_RMSE_M(i,k) = rm;
            %% Height Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(KE.v(k,:)),data.HMNorm(i,:));
            t_equation_HM{i,k} = eq; t_R2_HM(i,k) = r; t_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(KE.v(k,:)))',nonzeros(m.*data.HMNorm(i,:))');
            m_equation_HM{i,k} = eq; m_R2_HM(i,k) = r; m_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(KE.v(k,:)))',nonzeros(f.*data.HMNorm(i,:))');
            f_equation_HM{i,k} = eq; f_R2_HM(i,k) = r; f_RMSE_HM(i,k) = rm;

        end
        %% Knee Flexion
    else
        for j = 1:length(id)
            %             KF.v(1,j) = vol.(id{j}).Knee(1,2); KF.v(2,j) = vol.(id{j}).Knee(1,4);
            KF.v(1,j) = vol.(id{j}).Knee(2,2); % KF.v(4,j) = vol.(id{j}).Knee(2,4);
        end
        for k = 1;
            %% Raw Torque Linear Regressions
            [eq,r,rm] = linear_regression(table2array(KF.v(k,:)),data.Raw(i,:)); % Linear regression for all subjects
            t_equation_R{i,k} = eq; t_R2_R(i,k) = r; t_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(KF.v(k,:)))',nonzeros(m.*data.Raw(i,:))'); % Linear regression for males
            m_equation_R{i,k} = eq; m_R2_R(i,k) = r; m_RMSE_R(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(KF.v(k,:)))',nonzeros(f.*data.Raw(i,:))'); % Linear regression for females
            f_equation_R{i,k} = eq; f_R2_R(i,k) = r; f_RMSE_R(i,k) = rm;
            %% Limb Corrected Regression
            [eq,r,rm] = linear_regression(table2array(KF.v(k,:)),data.Corrected(i,:));
            t_equation_C{i,k} = eq; t_R2_C(i,k) = r; t_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(KF.v(k,:)))',nonzeros(m.*data.Corrected(i,:))');
            m_equation_C{i,k} = eq; m_R2_C(i,k) = r; m_RMSE_C(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(KF.v(k,:)))',nonzeros(f.*data.Corrected(i,:))');
            f_equation_C{i,k} = eq; f_R2_C(i,k) = r; f_RMSE_C(i,k) = rm;
            %% Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(KF.v(k,:)),data.MNorm(i,:));
            t_equation_M{i,k} = eq; t_R2_M(i,k) = r; t_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(KF.v(k,:)))',nonzeros(m.*data.MNorm(i,:))');
            m_equation_M{i,k} = eq; m_R2_M(i,k) = r; m_RMSE_M(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(KF.v(k,:)))',nonzeros(f.*data.MNorm(i,:))');
            f_equation_M{i,k} = eq; f_R2_M(i,k) = r; f_RMSE_M(i,k) = rm;
            %% Height Mass Normalized Regression
            [eq,r,rm] = linear_regression(table2array(KF.v(k,:)),data.HMNorm(i,:));
            t_equation_HM{i,k} = eq; t_R2_HM(i,k) = r; t_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(m.*table2array(KF.v(k,:)))',nonzeros(m.*data.HMNorm(i,:))');
            m_equation_HM{i,k} = eq; m_R2_HM(i,k) = r; m_RMSE_HM(i,k) = rm;
            [eq,r,rm] = linear_regression(nonzeros(f.*table2array(KF.v(k,:)))',nonzeros(f.*data.HMNorm(i,:))');
            f_equation_HM{i,k} = eq; f_R2_HM(i,k) = r; f_RMSE_HM(i,k) = rm;
        end
    end

end


%% Equation Extraction
% Extract the equation from the cell array (remove spaces and 'y =' part)
for l = 1:28
    for k = 1;
        equation = t_equation_R{l,k};
        equation = strrep(equation, ' ', ''); % Remove spaces
        equation = strrep(equation, 'y=', ''); % Remove 'y=' part
        % Split the equation to get the slope and intercept
        parts = strsplit(equation, 'x+'); % Assuming the format is always 'y = mx + b'
        slope(l,k) = str2double(parts{1}); % Convert slope from string to number
        intercept(l,k) = str2double(parts{2}); % Convert intercept from string to number
    end
end

% Determine Joint Movement and Angle order
subID = fieldnames(bd);
momDir = fieldnames(bd.(subID{1}).(subID{1}));
k = 1;
for i = 1:numel(momDir)
    angles = fieldnames(bd.(subID{1}).(subID{1}).(momDir{i}));
    angles = sort(angles);
    for j = 1:numel(angles)
        anglesList(k,1) = momDir(i);
        anglesList(k,2) = angles(j);
        k = k + 1;
    end
end

% clear angles equation i j k l parts tempR2 momDir

%% Scatter plots
for l = 1:28
    for k = 1
        equation = t_equation_R{l,k};
        equation = strrep(equation, ' ', ''); % Remove spaces
        equation = strrep(equation, 'y=', ''); % Remove 'y=' part
        % Split the equation to get the slope and intercept
        parts = strsplit(equation, 'x+'); % Assuming the format is always 'y = mx + b'
        slope(l,k) = str2double(parts{1}); % Convert slope from string to number
        intercept(l,k) = str2double(parts{2}); % Convert intercept from string to number

        equation = f_equation_R{l,k};
        equation = strrep(equation, ' ', ''); % Remove spaces
        equation = strrep(equation, 'y=', ''); % Remove 'y=' part
        % Split the equation to get the slope and intercept
        parts = strsplit(equation, 'x+'); % Assuming the format is always 'y = mx + b'
        slope(l,k+1) = str2double(parts{1}); % Convert slope from string to number
        intercept(l,k+1) = str2double(parts{2}); % Convert intercept from string to number

        equation = m_equation_R{l,k};
        equation = strrep(equation, ' ', ''); % Remove spaces
        equation = strrep(equation, 'y=', ''); % Remove 'y=' part
        % Split the equation to get the slope and intercept
        parts = strsplit(equation, 'x+'); % Assuming the format is always 'y = mx + b'
        slope(l,k+2) = str2double(parts{1}); % Convert slope from string to number
        intercept(l,k+2) = str2double(parts{2}); % Convert intercept from string to number

    end
end

x = linspace(0,2000);
close all
figure(1)
fc = [217,95,2]/255;
mc = [117,112,179]/255;
scatter(nonzeros(f.*table2array(AD.v)),nonzeros(f.*data.Raw(2,:)),'MarkerFaceColor',fc,'MarkerEdgeColor',fc,'Marker','o')
title('Ankle DF 15^o')
ylabel('Torque (N-m)')
xlabel('Volume (mL)')
hold on
scatter(nonzeros(m.*table2array(AD.v)),nonzeros(m.*data.Raw(2,:)),'MarkerFaceColor',mc,'MarkerEdgeColor',mc,'Marker','o')
xlim([0 350])
ylim([0 60])
plot(x,slope(2,1).*x+intercept(2,1),LineStyle="--",Color=[27,158,119]/255)
plot(x,slope(2,2).*x+intercept(2,2),LineStyle="--",Color=fc)
plot(x,slope(2,3).*x+intercept(2,3),LineStyle="--",Color=mc)
hold off

x = linspace(0,3000);
figure(2)
fc = [217,95,2]/255;
mc = [117,112,179]/255;
scatter(nonzeros(f.*table2array(AD.v)),nonzeros(f.*data.Raw(3,:)),'MarkerFaceColor',fc,'MarkerEdgeColor',fc,'Marker','o')
title('Ankle DF 30^o')
ylabel('Torque (N-m)')
xlabel('Volume (mL)')
hold on
scatter(nonzeros(m.*table2array(AD.v)),nonzeros(m.*data.Raw(3,:)),'MarkerFaceColor',mc,'MarkerEdgeColor',mc,'Marker','o')
xlim([0 350])
ylim([0 60])
plot(x,slope(3,1).*x+intercept(3,1),LineStyle="--",Color=[27,158,119]/255)
plot(x,slope(3,2).*x+intercept(3,2),LineStyle="--",Color=fc)
plot(x,slope(3,3).*x+intercept(3,3),LineStyle="--",Color=mc)
hold off

x = linspace(0,3500);
figure(3)
fc = [217,95,2]/255;
mc = [117,112,179]/255;
scatter(nonzeros(f.*table2array(HE.v)),nonzeros(f.*data.Raw(17,:)),'MarkerFaceColor',fc,'MarkerEdgeColor',fc,'Marker','o')
title('Hip Ex 30^o')
ylabel('Torque (N-m)')
xlabel('Volume (mL)')
hold on
scatter(nonzeros(m.*table2array(HE.v)),nonzeros(m.*data.Raw(17,:)),'MarkerFaceColor',mc,'MarkerEdgeColor',mc,'Marker','o')
xlim([0 3500])
ylim([0 225])
plot(x,slope(17,1).*x+intercept(17,1),LineStyle="--",Color=[27,158,119]/255)
plot(x,slope(17,2).*x+intercept(17,2),LineStyle="--",Color=fc)
plot(x,slope(17,3).*x+intercept(17,3),LineStyle="--",Color=mc)
hold off

x = linspace(0,3500);
figure(4)
fc = [217,95,2]/255;
mc = [117,112,179]/255;
scatter(nonzeros(f.*table2array(KF.v)),nonzeros(f.*data.Raw(27,:)),'MarkerFaceColor',fc,'MarkerEdgeColor',fc,'Marker','o')
title('Knee Fx 30^o')
ylabel('Torque (N-m)')
xlabel('Volume (mL)')
hold on
scatter(nonzeros(m.*table2array(KF.v)),nonzeros(m.*data.Raw(27,:)),'MarkerFaceColor',mc,'MarkerEdgeColor',mc,'Marker','o')
xlim([0 2000])
ylim([0 225])
plot(x,slope(27,1).*x+intercept(27,1),LineStyle="--",Color=[27,158,119]/255)
plot(x,slope(27,2).*x+intercept(27,2),LineStyle="--",Color=fc)
plot(x,slope(27,3).*x+intercept(27,3),LineStyle="--",Color=mc)
hold off

%% Box Plots
figure(3)
torques = data.Raw;
for i = 1:4
    volNorm(i,:) = torques(i,:)./table2array(AD.v);
end
for i = 5:8
    volNorm(i,:) = torques(i,:)./table2array(AP.v);
end
for i = 9:11
    volNorm(i,:) = torques(i,:)./table2array(HB.v);
end
for i = 12:14
    volNorm(i,:) = torques(i,:)./table2array(HD.v);
end
for i = 15:17
    volNorm(i,:) = torques(i,:)./table2array(HE.v);
end
for i = 18:20
    volNorm(i,:) = torques(i,:)./table2array(HF.v);
end
for i = 21:24
    volNorm(i,:) = torques(i,:)./table2array(KE.v);
end
for i = 25:28
    volNorm(i,:) = torques(i,:)./table2array(KF.v);
end
tvolNorm = sum(volNorm);
fvolNorm = mean(nonzeros(f.*tvolNorm));
mvolNorm = mean(nonzeros(m.*tvolNorm));
[vNormh,vNormp] = ttest2(nonzeros(f.*tvolNorm),nonzeros(m.*tvolNorm),'Vartype','unequal');
hold on
boxplot(nonzeros(f'.*tvolNorm'),'Positions',1,'Colors',fc)
boxplot(nonzeros(m'.*tvolNorm'),'Positions',2,'Colors',mc)
xticks([1,2])
xticklabels({'Female','Male'})
ylabel('Total (N-m/mL)')
xlim([0 3])
ylim([1 3])