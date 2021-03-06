%% Structural Dynamics and Vibration Control(M. Azimi et al.)
%% Example 5-6: Newmark Method

clc; clear; close all;
%% Parameters
% β = 0.25 -->  Average Accelration Method
% β = 0.167 --> Linear Accelration Method


ma = 110000;
k  = 10075582;
wn = sqrt(k/ma);

gamma = 0.5;
beta  = 0.25;

r = 0.07;
c = 2.0*r*sqrt(k*ma);

u(1) = 0;
v(1) = 0;
tt = 3.0;
n = 300;
n1 = n+1;
dt = tt/n;
td = .75;

a = ma/(beta*dt)+gamma*c/beta;
b = ma/(2.0*beta)+dt*c*(gamma/(2.0*beta)-1);
jk = td/dt;

%% load
p = zeros(n1,1);

jk1 = jk+1;

for n=1:jk1
    t = (n-1)*dt;
    p(n) = 450000*(1-t/td)*exp(-2.0*t/td);
end

an(1) = (p(1)-c*v(1)-k*u(1))/ma;
kh = k+ma/(beta*dt*dt)+gamma*c/(beta*dt);

for i=1:n1
    s(i) = (i-1)*dt;
end

for i=2:n1
    ww = p(i)-p(i-1)+a*v(i-1)+b*an(i-1);
    xx = ww/kh;
    zz = xx/(beta*dt*dt)-v(i-1)/(beta*dt)-an(i-1)/(2.0*beta);
    yy = (gamma*xx/(beta*dt)-gamma*v(i-1)/beta+dt*(1-gamma/(2.0*beta))*an(i-1));
    v(i) = v(i-1)+yy;
    an(i) = an(i-1)+zz;
    vv = dt*v(i-1)+dt*dt*(3.0*an(i-1)+zz)/6.0;
    u(i) = u(i-1)+vv;
end

%% Plot
figure(1); set(figure(1), 'Position', [100   100   800   600])

    subplot(2,2,1); grid on; hold on; box on;
    plot(s,p,'-k','LineWidth',2);
    set(gca, 'LineWidth',1, 'FontWeight','normal', 'FontName','Times New Roman', 'FontSize',14)
    xlabel('Time [s]', 'fontsize',16, 'fontname','Times New Roman','FontWeight','Bold')
    ylabel('Force [N]', 'fontsize',16, 'fontname','Times New Roman','FontWeight','Bold')

%% Displacement
    subplot(2,2,2); grid on; hold on; box on;
    plot(s,u,'-k','LineWidth',2);
    set(gca, 'LineWidth',1, 'FontWeight','normal', 'FontName','Times New Roman', 'FontSize',14)
    xlabel('Time [s]', 'fontsize',16, 'fontname','Times New Roman','FontWeight','Bold')
    ylabel('Displacement [m]', 'fontsize',16, 'fontname','Times New Roman','FontWeight','Bold')
    ylim([-.06 0.06])

%% Velocity
    subplot(2,2,3); grid on; hold on; box on;
    plot(s,v,'-k','LineWidth',2);
    set(gca, 'LineWidth',1, 'FontWeight','normal', 'FontName','Times New Roman', 'FontSize',14)
    xlabel('Time [s]', 'fontsize',16, 'fontname','Times New Roman','FontWeight','Bold')
    ylabel('Velocity [m/s]', 'fontsize',16, 'fontname','Times New Roman','FontWeight','Bold')
    ylim([-.31 0.31])

%% Acceleration
    subplot(2,2,4); grid on; hold on; box on;
    plot(s,an,'-k','LineWidth',2);
    set(gca, 'LineWidth',1, 'FontWeight','normal', 'FontName','Times New Roman', 'FontSize',14)
    xlabel('Time [s]', 'fontsize',16, 'fontname','Times New Roman','FontWeight','Bold')
    ylabel('Acceleration [m/s^2]', 'fontsize',16, 'fontname','Times New Roman','FontWeight','Bold')
    ylim([-4 4])

%% Print
    print('EX_5-6','-dpng')




