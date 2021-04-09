function [pH, pKb] = d11BtopH(d11B4,T,S,Z,d11Bsw,Mg,Ca,myami)

% This code was written by James Rae, University of St Andrews, to
% accompany Rae (2017), Boron isotopes in foraminifera: systematics,
% biomineralisation, and carbonate system reconstruction, AiG.  Please send
% any queries to jwbr@st-andrews.ac.uk.  Please cite reference above if
% using this code. 
% Calculates pH from d11B of borate at given temperature (C), salinity
% (psu), depth (m), d11Bsw (permil), [Mg] (mol/kg), [Ca] (mol/kg).
% Boron isotope calculations are based on correct mass balance equation
% treating each boron nuclide separately, given in Rae 2017 AiG. 
% For modern [Ca] & [Mg] uses Kb from Dickson (1990)
% In case of [Ca] & [Mg] not equal to modern, the MyAMI ion pairing model
% from Hain et al. 2015 is used.  A lookup table of this model's output is
% given in pK_CaMg_MyAMI.mat
% Pressure correction of Kb uses formulation of Zeebe & Wolf-Gladrow
% (2001).  The coefficients are often misquoted.  The correct set are from
% Millero 1979 (recalulated from Culberson and Pytlowicz 1968), as given by
% CO2SYS and Rae et al. (2011) 
% Alpha from Klochko et al. (2006)
% EXAMPLE
% d11B4 = [14; 15; 16]
% T = [25; 25; 25]
% S = [35; 35; 35]
% Z = [0; 0; 0]
% d11Bsw = [39.61; 39.61; 39.61]
% Mg = [52.8171; 52.8171; 52.8171]
% Ca = [10.2821; 10.2821; 10.2821]
% pH = fnd11BtopH_d11BswMgCa(d11B4,T,S,Z,d11Bsw,Mg,Ca)
% pH =
% 
%     7.4743
%     7.6738
%     7.8198

%% constants and environmentals

%constants
alpha       = 1.0272;
epsilon     = (alpha-1)*10^3;
BTref       = (0.0002414/10.811)*(35/1.80655)*10^6; %±1.62, from Lee (2010): B/Cl = 0.2414 and Sal/Cl = 1.80655 (Cox 1967)
R           = 83.14472;
Rstd        = 4.04367; %(951 ratio)
Rsw         = (d11Bsw./1000+1).*Rstd;

%state variables
P           = Z./10;
BT          = BTref*S./35;
Tk          = T + 273.15;


%% Kb calculate
% pK_CaMg = readtable('pK_CaMg_lookup.xlsx'); % load pre-saved version instead as quicker
% load pK_CaMg_MyAMI.mat
lnKb = zeros(size(T));
for jj = 1:length(Ca)
    
    Cajj = Ca(jj);
    Mgjj = Mg(jj);
    Tjj = T(jj);
    Tkjj = Tk(jj);
    Sjj  = S(jj);
    
    % Kb calculate - standard
    if Cajj == 10.2821 && Mgjj == 52.8171;
        
        tmp1	= -8966.9 - 2890.53.*Sjj.^0.5 - 77.942*Sjj + 1.728.*Sjj.^(3/2) - 0.0996.*Sjj.^2;
        tmp2	= 148.0248 + 137.1942.*Sjj.^0.5 + 1.62142.*Sjj;
        tmp3	= (-24.4344 - 25.085.*Sjj.^0.5 - 0.2474.*Sjj) .*log(Tkjj);
        lnKb(jj)    = tmp1./Tkjj + tmp2 + tmp3 + 0.053105*Sjj.^0.5 .*Tkjj;
        
    else
% using lookup table        
%         Car = round((Cajj/1000),3);
%         Mgr = round((Mgjj/1000),3);
%         
%         Caind = find(pK_CaMg.Ca==Car);
%         Mgind = find(pK_CaMg.Mg(Caind)==Mgr);
%         CaMgind = Caind(1)+Mgind-1
%         
%         lnKb(jj) = pK_CaMg.pKbp0(CaMgind) + pK_CaMg.pKbp1(CaMgind)*Sjj^0.5 + pK_CaMg.pKbp2(CaMgind)*Sjj + 1/Tkjj*(pK_CaMg.pKbp3(CaMgind) + pK_CaMg.pKbp4(CaMgind)*Sjj^0.5 + pK_CaMg.pKbp5(CaMgind)*Sjj + pK_CaMg.pKbp6(CaMgind)*Sjj^1.5 + pK_CaMg.pKbp7(CaMgind)*Sjj^2) + log(Tkjj)*(pK_CaMg.pKbp8(CaMgind) + pK_CaMg.pKbp9(CaMgind)*Sjj^0.5 + pK_CaMg.pKbp10(CaMgind)*Sjj) + pK_CaMg.pKbp11(CaMgind)*Tkjj*Sjj^0.5;
%
% call python in Matlab
%         PITZERpath = './CO2_Systematics/MyAMI/PITZER.py';
%         [K] = PyMyAMI(PITZERpath,num2str(Tjj),num2str(Sjj),num2str(Cajj/1000),num2str(Mgjj/1000));
%         lnKb_o(jj) = log(K.Kb(1)*K.Kb(2)/K.Kb(3));
        
        myami.calculate(Tjj,Sjj,Cajj/1e3,Mgjj/1e3);
        lnKb(jj) = log(myami.results("kb"));
    end
end

%% P correction - set-up of Zeebe & Wolf-Gladrow
a0	= -29.48;
a1	= 0.1622;
a2	= -0.002608;
b0	= -0.00284;
b1	= 0;
b2	= 0;
Pcor =-(a0+a1*T+a2*T.^2)/(R*Tk)*P+0.5*(b0+b1*T+b2*T.^2)/(R*Tk)*P.^2;

Kbval = exp(lnKb + Pcor);
pKb = -log10(Kbval);

RB4 = (d11B4./1000+1).*Rstd;

H = (Kbval.*RB4 - Kbval.*Rsw + Kbval.*RB4.^2.*alpha - Kbval.*RB4.*Rsw.*alpha)./(Rsw + RB4.*Rsw - RB4.*alpha - RB4.^2.*alpha);
pH = -log10(H);
