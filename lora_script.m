clear all; close all;

%% Parameters and Functions
rng(1);
samples = 1e4; % Number of simulations for averaging
eta=2.8; % path loss exponent
fc=868e6;    % Hz - Carrier Frequency
c=3e8;       % m/s^2 - c
lambda=c/fc; % m - Wavelength
Pt_db=14;     % dBm - Transmission Power
Pt = 10.^(Pt_db./10); % mW - Transmission Power
NF=6;                       % dB - Thermal Noise Power
BW=125e3;                   % Hz - Signal Bandwidth
Noise=-174+NF+10*log10(BW); % dBm - Additive White Gaussian Noise (AWGN)
E_db=[-123 -126 -129 -132 -134.5 -137]; % dBm - Receiver Sensitivity for SF 7 to 12
E = 10.^(E_db./10); % mW - Receiver Sensitivity for SF 7 to 12
gamma_db = 1; % dB - SIR Threshold
gamma = 10^(gamma_db/10); % linear - SIR Threshold
p = 1/100; % Duty Cycle
N_array = [500]; % Average Number of Devices

% Ring model distances
R = 3000; % m - Network radius
R_ring = [0 500 1000 1500 2000 2500 3000]; % m - rings radius
distances_sf = [1 100 200 300 400 500]; % m - points for each SF
d1 = [distances_sf(2:end)+R_ring(1) distances_sf+R_ring(2) distances_sf+R_ring(3) distances_sf+R_ring(4) distances_sf+R_ring(5) distances_sf+R_ring(6)]; % m - Points to simulate

% Ring Areas
Area_ring = zeros(1,6);
for i=1:6
    Area_ring(i) = R_ring(i+1).^2*pi - sum(Area_ring); % m^2 - Rings Area
end
Area_ring = Area_ring./(R^2*pi); % Normalized Rings Area

%Equations
g = @(d) (lambda./(4.*pi.*d)).^eta; % linear - Free Space Equation
h = @(m,n) raylrnd(sqrt(0.5),m,n).^2; % linear - Square Rayleigh Fading (exponential) rng%H1 = mean (h(samples)' >=  (E(1)./(Pt.*g(d1))));
f_d2 = @(r_in,r_out,c,l) sqrt(r_in^2 + (r_out^2-r_in^2).*rand(c,l)); % m - Interferer distance rng (r_in = inner radius; r_out = outer radius)

% Initializing vectors and matrixes
Q_1_sim = zeros(length(N_array),length(d1));
H_1_sim = zeros(1,length(d1));
H_1 = zeros(1,length(d1));
Q_1 = zeros(length(N_array),length(d1));

% Equations H_1 and Q_1
H1 = @(d1,n,sensi,ptx) exp(-(d1.^n)*(sensi/ptx)*((4*pi/lambda)^n));
Q1 = @(d1,sir,alpha,n,R1,R2) exp(-(alpha./(R2.^2 - R1.^2)).*(R2.^2.*hypergeom([1,2./n],1+2./n,-(R2.^n)./(sir.*(d1.^n))) - R1.^2.*hypergeom([1,2./n],1+2./n,-(R1.^n)./(sir.*(d1.^n)))));


%% H_1 equations and simulation
for d = 1:length(d1)
        d_a = d1(d);
        i = ceil(d_a/R_ring(2)); % ring number (SF7 -> 1, SF8 -> 2, ..., SF12 -> 6)
        H_1(d) = H1(d_a,eta,E(i),Pt); % Equation for H_1
        H_1_sim(d) = mean(h(1,samples)' >=  (E(i)./(Pt.*g(d1(d))))); % Simulated H_1
end

%% Q_1 equations
for N=1:length(N_array) %for different number of devices
    for d = 1:length(d1) %for each distance
        d_a = d1(d);
        i = ceil(d_a/R_ring(2)); % ring number (SF7 -> 1, SF8 -> 2, ..., SF12 -> 6)
        Q_1(N,d) = Q1(d_a,gamma,Area_ring(i)*N_array(N)*2*p,eta,R_ring(i),R_ring(i+1)); % Equation for Q_1
        q1_s = zeros(1,samples);
        for s = 1:samples %for each different sample to average over them
            h_i = h(1,1); % drawing d_1 rayleigh fading
            n_int = poissrnd(Area_ring(ceil(d_a/R_ring(2)))*N_array(N)*2*p,1); % drawing the number of interfering signals
            G_i = h(1,n_int) .* g(f_d2(R_ring(i),R_ring(i+1),1,n_int)); % drawing channel gain for each interfering signal, i.e., fading and pathloss
            q1_s(s) = ((h_i*g(d_a)) > (gamma*sum(G_i))); % Q_1 simulated
        end
        Q_1_sim(N,d) = mean(q1_s); % Q_1
    end
end


%% Fig2 Plot
figure
set(gcf, 'Units', 'centimeters')
set(gcf,'Position',[5 5 2*8.8 1.6*4.95])

plot(d1,H_1,'-r','LineWidth',2); hold on;
plot(d1,H_1_sim,'dr','MarkerSize',4,'LineWidth',2,'HandleVisibility', 'off');

plot(d1,Q_1,'--g','LineWidth',1.5);
plot(d1,Q_1_sim,'og','LineWidth',1.5,'MarkerSize',4,'HandleVisibility', 'off');

plot(d1,H_1.*Q_1,'b-.','LineWidth',1.5);
plot(d1,H_1_sim.*Q_1_sim,'sb','LineWidth',1.5,'MarkerSize',4,'HandleVisibility', 'off');

grid on;
legend('H_1','Q_1','H_1Q_1','Location','West')
set(gca,'FontSize',12)
xlabel('Distance [m]','fontsize',16);
ylabel('Success Probability','fontsize',16)
legend('boxoff')
%saveas(gcf,'simul_fig.eps','epsc')
%saveas(gcf,'simul_fig.fig')
