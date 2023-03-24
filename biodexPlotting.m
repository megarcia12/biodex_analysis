
%% Ankle
F03ankle0 = [min(F03.F03.ankle_df.pmvc.a0.rep1, F03.F03.ankle_df.pmvc.a0.rep2) 
             max(F03.F03.ankle_pf.pmvc.a0.rep1, F03.F03.ankle_pf.pmvc.a0.rep2)];
F03ankle15 = [min(F03.F03.ankle_df.pmvc.a15.rep1, F03.F03.ankle_df.pmvc.a15.rep2) 
             max(F03.F03.ankle_pf.pmvc.a15.rep1, F03.F03.ankle_pf.pmvc.a15.rep2)];
F03ankle30 = [min(F03.F03.ankle_df.pmvc.a30.rep1, F03.F03.ankle_df.pmvc.a30.rep2) 
             max(F03.F03.ankle_pf.pmvc.a30.rep1, F03.F03.ankle_pf.pmvc.a30.rep2)];
F03ankle45 = [min(F03.F03.ankle_df.pmvc.a45.rep1, F03.F03.ankle_df.pmvc.a45.rep2) 
             max(F03.F03.ankle_pf.pmvc.a45.rep1, F03.F03.ankle_pf.pmvc.a45.rep2)];

%% Hip Abd
F03hipAbd0 = [min(F03.F03.hip_ad.pmvc.a0.rep1, F03.F03.hip_ad.pmvc.a0.rep2)
              max(F03.F03.hip_ab.pmvc.a0.rep1, F03.F03.hip_ab.pmvc.a0.rep2)];
F03hipAbd10 = [min(F03.F03.hip_ad.pmvc.a10.rep1, F03.F03.hip_ad.pmvc.a10.rep2)
               max(F03.F03.hip_ab.pmvc.a10.rep1, F03.F03.hip_ab.pmvc.a10.rep2)];
F03hipAbd20 = [min(F03.F03.hip_ad.pmvc.a20.rep1, F03.F03.hip_ad.pmvc.a20.rep2)
               max(F03.F03.hip_ab.pmvc.a20.rep1, F03.F03.hip_ab.pmvc.a20.rep2)];

%% Hip FxEx
F03hipFE0 = [min(F03.F03.hip_ex.pmvc.a0.rep1, F03.F03.hip_ex.pmvc.a0.rep2)
             max(F03.F03.hip_fx.pmvc.a0.rep1, F03.F03.hip_fx.pmvc.a0.rep2)];
F03hipFE15 = [min(F03.F03.hip_ex.pmvc.a15.rep1, F03.F03.hip_ex.pmvc.a15.rep2)
              max(F03.F03.hip_fx.pmvc.a15.rep1, F03.F03.hip_fx.pmvc.a15.rep2)];
F03hipFE30 = [min(F03.F03.hip_ex.pmvc.a30.rep1, F03.F03.hip_ex.pmvc.a30.rep2)
              max(F03.F03.hip_fx.pmvc.a30.rep1, F03.F03.hip_fx.pmvc.a30.rep2)];

%% Knee FxEx
F03knee15 = [min(F03.F03.knee_fx.pmvc.a15.rep1, F03.F03.knee_fx.pmvc.a15.rep2) 
             max(F03.F03.knee_ex.pmvc.a15.rep1, F03.F03.knee_ex.pmvc.a15.rep2)];
F03knee40 = [min(F03.F03.knee_fx.pmvc.a40.rep1, F03.F03.knee_fx.pmvc.a40.rep2) 
             max(F03.F03.knee_ex.pmvc.a40.rep1, F03.F03.knee_ex.pmvc.a40.rep2)];
F03knee65 = [min(F03.F03.knee_fx.pmvc.a65.rep1, F03.F03.knee_fx.pmvc.a65.rep2) 
             max(F03.F03.knee_ex.pmvc.a65.rep1, F03.F03.knee_ex.pmvc.a65.rep2)];
F03knee90 = [min(F03.F03.knee_fx.pmvc.a90.rep1, F03.F03.knee_fx.pmvc.a90.rep2) 
             max(F03.F03.knee_ex.pmvc.a90.rep1, F03.F03.knee_ex.pmvc.a90.rep2)];

%% Plotting
F03ankle = [F03ankle0 F03ankle15 F03ankle30 F03ankle45];
F03ankleAng = [0 15 30 45];
F03knee = [F03knee15 F03knee40 F03knee65 F03knee90];
F03kneeAng = [15 40 65 90];
F03hipAbd = [F03hipAbd0 F03hipAbd10 F03hipAbd20];
F03hipAbdAng = [0 10 20];
F03hipFE = [F03hipFE0 F03hipFE15 F03hipFE30];
F03hipFEAng = [0 15 30];

figure(1)
subplot(2,2,1)
plot(F03ankleAng, F03ankle, ':o' ,'LineWidth', 2.5)
c
legend('Dorsiflexion','Plantarflexion','location', 'eastoutside')

subplot(2,2,2)
plot(F03kneeAng, F03knee, ':o' ,'LineWidth', 2.5)
title('Knee')
ylabel('Joint Moment (N-m)')
xlabel('Angle (Degrees)')
legend('Flexion','Extension','location', 'eastoutside')

subplot(2,2,3)
plot(F03hipAbdAng, F03hipAbd, ':o' ,'LineWidth', 2.5)
title('Hip Abd')
ylabel('Joint Moment (N-m)')
xlabel('Angle (Degrees)')
legend('Adduction','Abduction','location', 'eastoutside')

subplot(2,2,4)
plot(F03hipFEAng, F03hipFE, ':o' ,'LineWidth', 2.5)
title('Hip FxEx')
ylabel('Joint Moment (N-m)')
xlabel('Angle (Degrees)')
legend('Extension','Flexion','location', 'eastoutside')

F03mass = 46.2664;
F03ankle = [F03ankle0 F03ankle15 F03ankle30 F03ankle45]/F03mass;
F03knee = [F03knee15 F03knee40 F03knee65 F03knee90]/F03mass;
F03hipAbd = [F03hipAbd0 F03hipAbd10 F03hipAbd20]/F03mass;
F03hipFE = [F03hipFE0 F03hipFE15 F03hipFE30]/F03mass;

figure(2)
subplot(2,2,1)
plot(F03ankleAng, F03ankle, ':o' ,'LineWidth', 2.5)
title('Ankle')
ylabel('Joint Moment (N-m/kg)')
xlabel('Angle (Degrees)')
legend('Dorsiflexion','Plantarflexion','location', 'eastoutside')

subplot(2,2,2)
plot(F03kneeAng, F03knee, ':o' ,'LineWidth', 2.5)
title('Knee')
ylabel('Joint Moment (N-m/kg)')
xlabel('Angle (Degrees)')
legend('Flexion','Extension','location', 'eastoutside')

subplot(2,2,3)
plot(F03hipAbdAng, F03hipAbd, ':o' ,'LineWidth', 2.5)
title('Hip Abd')
ylabel('Joint Moment (N-m/kg)')
xlabel('Angle (Degrees)')
legend('Adduction','Abduction','location', 'eastoutside')

subplot(2,2,4)
plot(F03hipFEAng, F03hipFE, ':o' ,'LineWidth', 2.5)
title('Hip FxEx')
ylabel('Joint Moment (N-m/kg)')
xlabel('Angle (Degrees)')
legend('Extension','Flexion','location', 'eastoutside')