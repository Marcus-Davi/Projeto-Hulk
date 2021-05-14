%{
C�DIGO PARA APLICA��O DO FILTRO DE KALMAN

autor: William Santos
ano: 2021

1. PARTE
    Desenvolvimento da matriz Xk.
Xk = AX(k-1) + Bu
    Nosso X ter� dois elementos, o �ngulo e o bias (b). Nossa matriz u �
    referente a velocidade angular, esse dado obtido do girosc�pio.
    1 -deltaT
A = 0   1

B = deltaT
      0
2. PARTE

    Vamos trabalhar com dois Y, o primeiro vou chamar de y que � o y da
    estimativa, ele vai ser:

yk = CXk

C = 1
    0
    Enquanto eu vou ter o Y, que ser� o que utilizar� o aceler�metro, ele
    ser�:
Yk = �ngulo (j� � o valor do �ngulo calculado com os dados do aceler�metro)

erro = Yk - yk

3. PARTE

    Agora vamos trabalhar com a covari�ncia

    Pk = A*P(k-1)*A^T + Qn

Esse � o mesmo A do X, e esse Qn � um par�metro de atualiza��o por conta do
girosc�pio. 

Qn = 0.001*[mean_time^2/2 0;0 mean_time]
    Matriz 2x2

4. PARTE
   Calcular o ganho.
    Para isso precisamos calcular o S

S = C*Pk*C^T + Rn

Esse R tem a ver com a vari�ncia do nosso sensor aceler�metro, podemos
calcular com ele parado e deixar o valor a�.

K = Pk*C^T*S^-1

5. PARTE
    Atualiza��o do nosso X

Xk-1 = Xk

PRONTO PARA COME�AR
%}      
%% Setup
clear; 
clc;

display('Dado a ser lido:');
[accx accy accz gyrox gyroy gyroz] = read_mpu_arq();

tam = length(accx);

display('Dados para a calibra��o:');
[accx_0,accy_0,accz_0,gyrox_0,gyroy_0,gyroz_0] = bias_calculation(0,0,tam,1);

%% Calibration

accx = accx + accx_0;
accy = accy + accy_0;
accz = accz + accz_0;

gyrox = gyrox + gyrox_0;
gyroy = gyroy + gyroy_0;
gyroz = gyroz + gyroz_0;


%% Calculando T e �ngulos
T = 1/100;  

var_pitch = 0.025; 
var_roll = 0.025; 

pitch = -atan2(accx,sqrt(accz.*accz+accy.*accy)); %Nossa medi��o, fica no Y
roll = atan2(accy,sqrt(accz.*accz+accx.*accx));

P = eye(4);
Qn = 0.01*[T^2/2 0 0 0;0 T 0 0;0 0 T^2/2 0;0 0 0 T];
Rn = [var_pitch 0;0 var_roll];

X = zeros(2,tam); %Linha 1 --> pitch e Linha 2 --> roll
x = [0 0 0 0]';

A = [1 -T 0 0;0 1 0 0;0 0 1 -T;0 0 0 1];
B = [T 0;0 0;0 T;0 0];
C = [1 0 0 0;0 0 1 0];

%% Loop
   
for i = 1:tam
    
    u = [gyroy(i);gyrox(i)];
    
    x_ = A*x + B*u;
    P = A*P*A' + Qn;
    
    y_ = C*x;
    y_medido = [pitch(i);roll(i)];
    
    erro = y_medido - y_;
    
    S = C*P*C' + Rn;
    K = (P*C')*inv(S);
    
    x = x_ + K*erro;
    
    P = (eye(4) - K*C)*P;
    
    X(1,i) = x(1,1); % pitch
    X(2,i) = x(3,1); % roll
end
    k_pitch = X(1,:);
    k_roll = X(2,:);
    
   %[cf_pitch,cf_roll,gyro_y,gyro_x,acc_p,acc_r] = complementary_filter();
   
   %%{
   figure;
   
   subplot(1,2,1);
   plot(k_pitch,'-b');
   hold on;
   %plot(cf_pitch,'-r');
  ylim([-1.7 1.7]);
  % legend('Kalman Pitch','Complementar Pitch');
   title('PITCH');
   hold off;
   subplot(1,2,2);
   
   plot(k_roll,'-b');
   hold on;
  % plot(cf_roll,'-r');
   ylim([-1.7 1.7]);
   %legend('Kalmam Roll','Complementar Roll');
   title('ROLL');
   hold off;
 %}
  