tau = [];
A = [];
k=[];
C=[];

tau(end+1,1)= processSignal(readtable('vivian_be.csv')).decayRate ;

tau(end+1,1)= processSignal(readtable('vivian2_be.csv')).decayRate ;
tau(end+1,1)= processSignal(readtable('jihye_be.csv')).decayRate ;
tau(end+1,1)= processSignal(readtable('jihye2_be.csv')).decayRate ;
tau(end+1,1)= processSignal(readtable('t_be.csv')).decayRate ;
tau(end+1,1)= processSignal(readtable('sara_be.csv')).decayRate ;
tau(end+1,1)= processSignal(readtable('gihyun_be.csv')).decayRate ;
tau(end+1,1)= processSignal(readtable('june_be.csv')).decayRate ;

tau(1,2)= processSignal(readtable('vivian_nb.csv')).decayRate ;
tau(2,2)= processSignal(readtable('vivian2_nb.csv')).decayRate ;
tau(3,2)= processSignal(readtable('jihye_nb.csv')).decayRate ;
tau(4,2)= processSignal(readtable('jihye2_nb.csv')).decayRate ;
tau(5,2)= processSignal(readtable('t_nb.csv')).decayRate ;
tau(6,2)= processSignal(readtable('sara_nb.csv')).decayRate ;
tau(7,2)= processSignal(readtable('gihyun_nb.csv')).decayRate ;
tau(8,2)= processSignal(readtable('june_nb.csv')).decayRate ;

figure;
boxplot(tau);
xlabel('B.E.','No B.E.')
%todo:fix
ylabel('Decay Constant (tau)')

[h,p,ci,stats]=ttest(tau(:,1),tau(:,2));