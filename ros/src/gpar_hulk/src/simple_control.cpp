#include "ros/ros.h"
#include "geometry_msgs/Point.h"
#include <cmath>
#include <iostream>
#include <vector>

//Variáveis para realizar o controle
geometry_msgs::Point velocidade;

int contador = 0;
float u,v=1,w,Kp = 10,tol=0.1,errox=1,erroy=1,R=0.08,L=0.16,theta;
std::vector<float> x{0,0,2,2,0},y{0,2,2,0,0};

//Função que vai receber os dados da posição do Coppelia e fazer o cálculo de W e V
void Dados_Posicao(const geometry_msgs::Point::ConstPtr& posicao_atual){
	if((std::abs(errox)>tol || std::abs(erroy)>tol)){

	errox = x[contador] - posicao_atual->x;
	erroy = y[contador] - posicao_atual->y;
	
	//Obs: em z foi colocado o theta, já que a posição Z não é utilizada.
	theta = atan2(erroy,errox);	
	
	u = theta - posicao_atual->z;

	u = atan2(sin(u),cos(u));

	w = Kp*u;
	
	v = sqrt(errox*errox + erroy*erroy);

	}
	else{
		v = 0;
		
		errox = x[contador] - posicao_atual->x;
		erroy = y[contador] - posicao_atual->y;
		
		if(std::abs (errox)<=tol && std::abs(erroy)<=tol)
			contador++;
		
		if(contador == 5)
			contador = 0;	
	
}
	ROS_INFO("Posicao X: %.2f\nPosicao Y: %.2f\nTheta: %.2f\nU: .%2f\nW: .%2f\nV: %.2f\nx= %.2f\ny = %.2f\nerrox = %.2f\nerroy = %.2f\n",posicao_atual->x,posicao_atual->y,posicao_atual->z,u,w,v,x[contador],y[contador],errox,erroy);

}

int main(int argc, char **argv){
	ros::init(argc,argv,"simple_cotrol");
	
	ros::NodeHandle n("~");

	ros::Subscriber sub_pos = n.subscribe("/dados_coppelia",1000,Dados_Posicao);

	ros::Publisher pub_vel = n.advertise<geometry_msgs::Point>("/comando1",1000);
	
	ros::Rate r(20);
	
	while(ros::ok()){	
		velocidade.x = (2*v-w*L)/(2*R); //Velocidade da Roda Esquerda
		velocidade.y = (2*v+w*L)/(2*R); //Velocidade da Roda Direita
		
		pub_vel.publish(velocidade);
		r.sleep();

	ros::spinOnce();
	}
	
return 0;
}
