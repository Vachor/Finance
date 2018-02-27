NPts = 10;
Eret = [0.1;0.2;0.15];
ECov = 100 * [0.005,-0.010,0.004;
           -0.010,0.040,-0.002;
           0.004,-0.002,0.023];
ERet = Eret(:);   %make sure it is a colum vector
NAssets = length(Eret);  %get number of assets
V0 = zeros(NAssets,1)  %分配权重的下限向量
V1 = ones(1,NAssets);
options = optimset('LargeScale', 'off');

%找到使得利润最大的权重分配
MaxReturnWeights = linprog(-ERet, [], [], V1, 1, V0);
MaxReturn = MaxReturnWeights' * Eret;

%找到使得风险最小的权重分配
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
A = [V1 ; VConstr];     %等式约束左边
B = [1 ; 0];     %等式约束右边
for point = 2:NumFrontPoints
    B(2) = RTarget(point);    %不断的改变portfolio return的值
    Weights = quadprog(ECov,V0,[],[],A,B,V0,[],[],options);
    PRoR(point) = dot(Weights,ERet);
    PRisk(point) = sqrt(Weights'*ECov*Weights);
    PWts(point,:) = Weights(:)';
end

plot(PRisk,PRoR);