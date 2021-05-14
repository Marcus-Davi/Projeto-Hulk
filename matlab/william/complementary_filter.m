%% Descri��o do c�digo
%{
Autor: William Santos
Ano: 2020

Objetivo do c�digo:
- Realizar o filtro complementar dos dados do girosc�pio e do aceler�metro. 

Configura��es necess�rias:
- Voc� pode alterar o valor de "a" se desejado, esse valor indica a
contribui��o do girosc�pio e do aceler�metro para o filtro. Voc� pode
alterar esse valor at� estar em um n�vel adequado. 

Fun��es Utilizadas: 
- Utilizamos 3 fun��es nesse c�digo
    1. read_mpu_arq (Respons�vel por ler os dados de um arquivo csv, que
    contenha os dados do girosc�pio e aceler�metro)
    2. bias_calculation (Respons�vel por ler os dados de um arquivo csv e
    calcular o bias, recomend�vel esse arquivo ser do MPU em repouso)
    3. angle_gyro_accel_mpu (A partir dos dados coletados, e feito os
    devidos ajustes com o bias, esses dados ser�o enviados para essa fun��o
    que calcula os �ngulos do girosc�pio e do aceler�metro).

Como utilizar o c�digo:
    N�o precisamos de nenhum par�metro para a execu��o do c�digo. No
    momento de execu��o, precisaremos indicar dois arquivos
    1. O primeiro arquivo � para a leitura dos dados do mpu, do movimento
    que fizemos com o componente, ou at� do mesmo em repouso.
    2. O segundo arquivo que indicamos � o que ser� usado para calcular o
    bias.
    Com essas duas informa��es, o c�digo continua e plota, ao final, os
    dados do girosc�pio, do aceler�metro e do filtro complementar, em dois
    gr�ficos, um representando o ROLL e o outro o PITCH. 

Importante indicar que ROLL � o giro ao redor do eixo x. Enquanto o PITCH �
o giro ao redor do eixo y. E por fim, o YAW � o giro ao redor do eixo Z.
%}
function [cf_pitch,cf_roll,gyro_y,gyro_x,acc_p,acc_r,accx,accy,accz,gyrox,gyroy,gyroz] = complementary_filter()
clc;
%% SETUP
    display('O pr�ximo arquivo � para leitura dos dados');
[accx accy accz gyrox gyroy gyroz] = read_mpu_arq();

    display('O pr�ximo arquivo � para a calibra��o');
[accx_0,accy_0,accz_0,gyrox_0,gyroy_0,gyroz_0] = bias_calculation(0,0,0,1);

%% Calibra��o

accx = accx + accx_0;
accy = accy + accy_0;
accz = accz + accz_0;

gyrox = gyrox + gyrox_0;
gyroy = gyroy + gyroy_0;
gyroz = gyroz + gyroz_0;

%% �ngulos
freq = 100;

[acc_p, acc_r , gyro_y, gyro_x] = angle_gyro_accel_mpu(accx,accy,accz,gyrox,gyroy,gyroz);

%[acc_p acc_r] = linear_aceleration(gyrox,gyroy,gyroz,accx,accy,accz,acc_p,acc_r);

%% Complementary Filter
  
   cf_roll = zeros(length(accx),1);
   cf_pitch = zeros(length(accx),1);
   
   a = 0.98;
   
   for i = 2:length(accx)
      cf_pitch(i) = a*(cf_pitch(i-1)+gyro_y(i)-gyro_y(i-1))+(1-a)*acc_p(i);  
      cf_roll(i) = a*(cf_roll(i-1)+gyro_x(i)-gyro_x(i-1))+(1-a)*acc_r(i);  
   end
   
%% Plotagem
   %%{
   subplot(1,2,1);
   %plot(gyro_y,'-b');
   hold on;
   %plot(acc_p,'-g');
   plot(cf_pitch,'-g');
  ylim([-1.7 1.7]);
  % legend('Gyro Angle','Accel_Angle','Complementary Filter');
   title('PITCH');
   hold off;
   subplot(1,2,2);
   
  % plot(gyro_x,'-b');
   hold on;
  % plot(acc_r,'-g');
   plot(cf_roll,'-g');
   ylim([-1.7 1.7]);
   %legend('Gyro Angle','Accel_Angle','Complementary Filter');
   title('ROLL');
   hold off;
%}

end

