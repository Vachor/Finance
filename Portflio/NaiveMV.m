NPts = 10;
Eret = [0.1;0.2;0.15];
ECov = 100 * [0.005,-0.010,0.004;
           -0.010,0.040,-0.002;
           0.004,-0.002,0.023];
ERet = Eret(:);   %make sure it is a colum vector
NAssets = length(Eret);  %get number of assets
V0 = zeros(NAssets,1)  %����Ȩ�ص���������
V1 = ones(1,NAssets);
options = optimset('LargeScale', 'off');

%�ҵ�ʹ����������Ȩ�ط���
MaxReturnWeights = linprog(-ERet, [], [], V1, 1, V0);
MaxReturn = MaxReturnWeights' * Eret;

%�ҵ�ʹ�÷�����С��Ȩ�ط���
MinVarWeights = quadprog(ECov,V0,[],[],[V1;Eret'],[1;0],V0,[],[],options);
MinVarReturn = MinVarWeights' * ERet;
MinVarStd = sqrt(MinVarWeights' * ECov * MinVarWeights);

% check if there is only one efficient portfolio
if MaxReturn > MinVarReturn
    RTarget = linspace(MinVarReturn, MaxReturn, NPts);
    NumFrontPoints = NPts;
else
    RTarget = MaxReturn;
    NumFrontPoints = 1;
end

% Store first portfolio
PRoR = zeros(NumFrontPoints, 1);
PRisk = zeros(NumFrontPoints, 1);
PWts = zeros(NumFrontPoints, NAssets);
PRoR(1) = MinVarReturn;
PRisk(1) = MinVarStd;
PWts(1,:) = MinVarWeights(:)';

%trace frontier by changing target return
VConstr = ERet';
A = [V1 ; VConstr];     %��ʽԼ�����
B = [1 ; 0];     %��ʽԼ���ұ�
for point = 2:NumFrontPoints
    B(2) = RTarget(point);    %���ϵĸı�portfolio return��ֵ
    Weights = quadprog(ECov,V0,[],[],A,B,V0,[],[],options);
    PRoR(point) = dot(Weights,ERet);
    PRisk(point) = sqrt(Weights'*ECov*Weights);
    PWts(point,:) = Weights(:)';
end

plot(PRisk,PRoR);