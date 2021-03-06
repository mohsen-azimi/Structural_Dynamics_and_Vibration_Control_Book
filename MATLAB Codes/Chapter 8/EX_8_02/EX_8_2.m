%% Structural Dynamics and Vibration Control(M. Azimi et al.)
%% Example 8-2: Response of A 3-story Shear Frame

clear; close all; clc
%% Parameters
% earthquake = f_loadEarthquake('ElCentro',g [unit],dt,Tend);
earthquake = f_loadEarthquake('ElCentro',9.806,0.01,60);

xddot_g = earthquake.xddot_g;
t = earthquake.t;
dt = earthquake.dt;
g = earthquake.g;
%% Structural Parameters, [Ms], [Ks], [Cs]
n = 3; % Number of stories
r = 3; % Number of controllers
Ms = 3000*diag([345.6 345.6 345.6]); % Mass matrix (kgm)
Ks = 3.8*10^8*[2.4 -1.2 0;
    -1.2 2.4 -1.2;
    0 -1.2 1.2]; % Stiffness matrix (N/m)
[~,wn2] = eig(Ks/Ms);
wn = sqrt(diag(wn2));
Tn = 2*pi./wn;
xi1 = 0.01; xi2 = 0.01; % Daming ratios of 1st and 2nd natural frequencies
Ralpha = 2*wn(1)*wn(2)*((xi1*wn(2)-xi2*wn(1))/(wn(2)^2-wn(1)^2));
Rbeta = 2*(xi2*wn(2)-xi1*wn(1))/(wn(2)^2-wn(1)^2);
Cs = Ralpha*Ms+Rbeta*Ks; % Cs = Reighly’s Damping Matrix

%%
% [γ] , {δ}
for i = 1:n
    for j = 1:r
        if i == j gamma(i,j) = 1;
        elseif i == j-1 gamma(i,j) = -1;
        else gamma(i,j) = 0;
        end
    end
end
delta = -diag(Ms);

%% Plot
% State-space parameters
% {Z} = {x;xdot} , {Zdot} = [A]Z+Bu{u}+{Br}xddot_g
O = zeros(n); I = eye(n);
A = [O I
    (-Ms^-1)*Ks (-Ms^-1)*Cs];
Bu = [ O
    (Ms^-1)*gamma];
Br = [zeros(n,1)
    (Ms^-1)*delta];
B = [ O
    (Ms^-1) ];
C = [I O
    O I];
D = zeros(size(B)) ;


%% Uncontrolled response using LSIM
sys = ss(A,B,C,D);
Ones = ones(n,1);
Fe = -Ms*Ones*xddot_g'; % Earthquake Force
[Y,~,~] = lsim(sys,Fe,t); % [Y,tt1,X1]=lsim(sys,u,t)
YY = mat2cell(Y',[n,n]);
unControlled.Y = Y';
unControlled.displ = YY{1,1};
unControlled.vel = YY{2,1};

%% Controlled using LQR/Ricatti Eqn.
R = 10^-6*eye(n); % [R]
Q = 10^6*eye(2*n); % [Q]
P = care(A,Bu,Q,R); % [P] in Ricatti equation
G = R^-1*Bu'*P; % Control Gain Matrix
% G = G*0 (uncontrolled system)
% G = lqr(A, Bu, Q, R); (same as the above one)
% Build [T] which is the eig vectror of A
[v,~] = eig(A);
for i = 1:n
    vv(:,i) = v(:,2*i-1);
end
for i = 1:n
    T_help(:,i) = vv(:,n+1-i);
    T(:,(2*(i-1)+1)) = real(T_help(:,i));
    T(:,(2*(i-1)+2)) = imag(T_help(:,i));
end
Phi = T^-1*A*T;
for i = 1:n
    Phi(i,n+1:end) = 0;
    Phi(n+1:end,i) = 0;
end
%% i = 1,or t = 0: Initial Conditions & Prealloactions
u = zeros(r,max(size(xddot_g)));
Z = zeros(2*n,max(size(xddot_g)));
Psi = zeros(2*n,max(size(xddot_g)));
Gamma = zeros(2*n,max(size(xddot_g)));
Lambda = zeros(2*n,max(size(xddot_g)));
i = 1;

Gamma(:,i) = T^-1*Bu*u(:,i)+T^-1*Br*xddot_g(i);
Lambda(:,i) = expm(zeros(2*n))*Gamma(:,i);
Psi(:,i) = T^-1*Z(:,i);
%% i = 2, t = 0+dt (u = 0 between t = 0 t = dt)
i = 2;
Gamma(:,i) = ( T^-1*Bu*u(:,i))+( T^-1*Br*xddot_g(i));
Psi(:,i) = Lambda(:,i-1)+Gamma(:,i)*dt/2;
Z(:,i) = T*Psi(:,i);
u(:,i+1) = -G*Z(:,i);
%% i = 3+, t = 0+2dt,…, end
for i = 3:numel(t)
    Gamma(:,i) = ( T^-1*Bu*u(:,i) )+( T^-1*Br*xddot_g(i) );
    Lambda(:,i-1) = expm(Phi*dt)*(Lambda(:,i-2)+Gamma(:,i-1)*dt);
    Psi(:,i) = Lambda(:,i-1)+Gamma(:,i)*dt/2;
    Z(:,i) = T*Psi(:,i);
    u(:,i+1) = -G*Z(:,i);
end
u(:,i+1) = []; % For dimension match for plotting
Controlled.displ = Z(1:n,:);
Controlled.vel = Z(n+1:end,:);
%% Plot

figure(1); set(figure(1), 'Position', [100   100   1400   600])

for i = 1:n
    subplot(n+1,3,3*i-1); plot(t, Z(n+1-i,:),'LineStyle','-','LineWidth',1,'Color',[0 0 0]);title(['Uncontrolled Displacement @ Story', num2str(n+1-i)]);
    subplot(n+1,3,3*i-2); plot(t, unControlled.displ(n+1-i,:),'LineStyle','-','LineWidth',1,'Color',[0 0 0]);title(['Controlled Displacement @ Story', num2str(n+1-i)]);
    subplot(n+1,3,3*i); plot(t, u(n+1-i,:),'LineStyle','-','LineWidth',1,'Color',[0 0 0]);title(['Control Force @ Story', num2str(n+1-i)]);
end
subplot(n+1,3,3*n+1:3*n+3); plot(t, xddot_g/g,'LineStyle','-','LineWidth',1,'Color',[0 0 0]);title(['Uncontrolled Displacement @ Story', num2str(n)]);
%% Print
print('EX_8_2','-dpng')