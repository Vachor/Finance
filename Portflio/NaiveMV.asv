Eret = [0.1;0.2;0.15]
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
MinVarWeights = quadprog(ECov,V0,[],[],V1,1,V0,[],[],options);
MinVarReturn = MinVarWeights' * ERet;
MinVarStd = sqrt(MinVarWeights' * ECov * MinVarWeights);

if MaxReturn > MinVarReturn
    RTarget = linspace(MinVarReturn, MaxReturn, NPts);
    NumFrontPoints = NPts;
else
    RTarget = MaxReturn;
    NumFrontPoints = 1;