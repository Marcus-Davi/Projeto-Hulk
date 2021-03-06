#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import rospy
from geometry_msgs.msg import Twist, Pose2D, Vector3
from turtlesim.msg import Pose
from math import pi, atan2, sqrt, cos, sin, tan
import sys
import paths

#USO COM O SIMULADOR DO VREṔ & TURTLESIM
def updatePose(pose): 
    #rospy.loginfo(weel_vel)

    position.x = pose.x 
    position.y = pose.y 
    position.theta = pose.z
    #rospy.loginfo(position)


rospy.init_node('hulk_controller', anonymous=True)

#COPPELIA
velocity_publisher = rospy.Publisher('/velocidade_hulk', Twist, queue_size=10)
pose_subscriber = rospy.Subscriber('/measured_pose', Vector3, updatePose)
#vel_subscriber = rospy.Subscriber('/measured_velocity', Vector3, updatePose)


#TARTARUGA DO ROS
#velocity_publisher = rospy.Publisher('/turtle1/cmd_vel', Twist, queue_size=10) 
#pose_subscriber = rospy.Subscriber('/turtle1/pose', Pose, updatePose)

position = Pose2D()
position.x = 0
position.y = 0
position.theta = 0

l = 0.38    #dados do Prioneer do coppelia
r = 0.185/2 #dados do Prioneer do coppelia

def go2goal(xgoal = 0, ygoal = 0, thetagoal = 0):
    '''Implementa um controle que manda o robo ir da posição atual para a posição desejada;
    '''
    goal = Pose2D()
    goal.x = xgoal
    goal.y = ygoal
    goal.theta = thetagoal

    erro_acumulado = 0
    tol = 0.05
    v = 10
    w = 0

    #PID {
    kp = 0.5
    ki = 0.00005
    #kd = 0
    #    }
    rate = rospy.Rate(20)

    while not rospy.is_shutdown():
        rate.sleep()
        if(v > tol):
            errox = goal.x - position.x 
            erroy = goal.y - position.y     
            
            ux = errox
            uy = erroy

            theta_r = atan2(uy, ux)

            v = sqrt(ux**2 + uy**2)
            
            errot = theta_r - position.theta # erro do angulo theta
            errot = atan2(sin(errot), cos(errot))

            erro_acumulado += errot 

            w = kp * errot + ki *  erro_acumulado #PI
            vel = Twist()

            if(v > 0.7):
                v = 0.7
            elif(v < -0.7):
                v = -0.7

            vel.linear.x = v
            vel.linear.y = 0
            vel.linear.z = 0

            vel.angular.x = 0
            vel.angular.y = 0
            vel.angular.z = w

            #rospy.loginfo(vel)
            velocity_publisher.publish(vel)
            #rospy.logwarn(vel)

        else :
            rospy.logwarn('cabou!')
            #vel.linear.x = 0
            #vel.angular.z = 0
            #velocity_publisher.publish(vel)
            return
        
    #pose_subscriber.unregister()

def parar():
    '''Para o robo
    '''
    vel = Twist()
    vel.linear.x  = 0
    vel.angular.z = 0
    velocity_publisher.publish(vel)

if __name__ == "__main__":
    try:
        # Fazer lista
        path = list()
        theta = 0
        #path = paths.quadrado()
        path = [(5,0)]

        #print(path)
        for points in path:
            x = points[0]
            y = points[1]   
            go2goal(x,y,theta)
        
        parar()
        

    except rospy.ROSInterruptException :
        pass