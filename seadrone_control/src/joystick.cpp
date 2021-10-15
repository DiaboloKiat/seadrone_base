#include "ros/ros.h"
#include "std_msgs/String.h"
#include "std_msgs/Int16.h"
#include "sensor_msgs/Joy.h"

// udpUser
#include "CUDPCommUser.hpp"
#include <iostream>
#include <math.h>
#include <sys/wait.h>
#include <string>
#include <sstream>
using namespace std;

bool motor = false;
//std_msgs::Int16 gripper;

//LED
int led_brightness_top = 0;
int led_brightness_bot = 0;

//Camera
float gimbal_Pitch = 0.314;

//motor
float c_forces_moments_[2]={0};
double max_motor = 3;  //max 1~12
int depth_flag = 0;
int last_depth_flag = 0;
double delta_depth = 0;
double yaw = 0;   //z axis

void morse_cb(const std_msgs::Int16::ConstPtr& msg)
{
  ROS_INFO("I heard: [%i]", msg->data);
  if(msg->data == 1)
  {
    //led_brightness_top = 10;
    led_brightness_bot = 2;
  }
  else
  {
    //led_brightness_top = 0;
    led_brightness_bot = 0;
  }
}

void joy_cb(const sensor_msgs::Joy::ConstPtr& msg)
{
  //button: RB(5) LB(4)
  if(msg->buttons[5]==1)
  {
    motor = true;
    max_motor = 3;
    ROS_INFO("Motor start!!! (Normal speed)");
  }
  else if(msg->buttons[4]==1)
  {
    motor = true;
    max_motor = 5;
    ROS_INFO("motor start!!! (Max speed)");
  }
  else if(msg->buttons[5]==0 && msg->buttons[4]==0)
  {
    motor = false;
    ROS_INFO("motor stop!!! (None speed)");
  }

  //button: Y(3) A(0)
  if (msg->buttons[0]==1 && gimbal_Pitch<1.5) //(msg->axes[1]==-1 && gimbal_Pitch<1.57)
    gimbal_Pitch+=0.157;
  if (msg->buttons[3]==1 && gimbal_Pitch>-0.7)
    gimbal_Pitch-=0.157;

  //button: X(2) B(1)
  if (msg->buttons[1]==1 && led_brightness_top<100)
  {
    led_brightness_top+=5;
    //led_brightness_bot+=5;
  } 
  if (msg->buttons[2]==1 && led_brightness_top>0)
  {
    led_brightness_top-=5;
    //led_brightness_bot-=5;
  }

  //joy.axes: (5)RT -1～１
  if(msg->axes[5]==-1)
  {
    led_brightness_bot = 100;
  }
  else if(msg->axes[5]==1 || msg->axes[5]==0)
  {
    led_brightness_bot = 0;
  }

  /*/gripper
  //button: Start(7) Back(6)
  if(msg->buttons[7]==1)
  {
    gripper.data = 1;
  }
  else if(msg->buttons[6]==1)
  {
    gripper.data = 2;
  }
  else if(msg->buttons[7]==0 && msg->buttons[6]==0)
  {
    gripper.data = 0;
  }
  */
    
  //motor
  //joy.axes: (3)joystick R_x -1~1  (4)joystick R_y -1~1
  c_forces_moments_[1] = (msg->axes[3])*max_motor;
  c_forces_moments_[0] = (msg->axes[4])*max_motor;
  
  //joy.axes: (7)x+ U=1~D=-1
  if(msg->axes[7]==1)
  { 
    delta_depth=1;
    depth_flag=1;
  }
  else if(msg->axes[7]==-1)
  {   
    delta_depth=-1;   
    depth_flag=1;  
  }
  else
  {
    delta_depth=0;
    depth_flag=0;
  }

  //joy.axes: (６)x+ L=1~R=-1
  if(msg->axes[6]==-1)
  {
    yaw-=30;
  }
  if(msg->axes[6]==1)
  {
    yaw+=30;
  }
  cout << delta_depth << " " << yaw << endl;
}


int main(int argc, char **argv) 
{
  ros::init(argc, argv, "joystick_node");
  ros::NodeHandle n;
  ros::Subscriber sub_joy = n.subscribe("/seadrone/joy", 1000, joy_cb);
  ros::Subscriber sub_morse = n.subscribe("/seadrone/morse_code", 1000, morse_cb);
  // ros::Publisher gripper_pub = n.advertise<std_msgs::Int16>("/seadrone/gripper", 1000);
  printf("Start\n");

  /* udp communication */
  orobotix::CUDPCommUser udpUser_;
  orobotix::SRobotDataUser robotData;

  // initialize the flag
  robotData.flag_enable_camera_[0] = 1;
  robotData.flag_enable_camera_[1] = 0;
  robotData.flag_enable_camera_[2] = 0;
  robotData.flag_enable_individual_control_ = false;
  robotData.flag_enable_thruster_ = false;

  // set communication
  robotData.droneIP_ = "192.168.0.122";
  robotData.dronePort_ = 8090;
  robotData.config_id_ = 1;

  robotData.drone_please_power_off = false;
  
  robotData.led_brightness_top_ = 5;
  //robotData.led_brightness_bot_ = 10;

  // thruster
  robotData.initThrusterInfo(5);

  // initialize the udp communication
  udpUser_.init(&robotData);

  
  while(ros::ok())  
  {
    robotData.gimbal_Pitch_ = gimbal_Pitch;
    robotData.led_brightness_top_ = led_brightness_top;
    robotData.led_brightness_bot_ = led_brightness_bot;
    
    if(motor)
    {
      robotData.flag_enable_thruster_ = true;
      robotData.c_forces_moments_[0]=c_forces_moments_[0];
      robotData.c_forces_moments_[1]=c_forces_moments_[1]; 
      robotData.c_forces_moments_[2] = delta_depth/200;

      robotData.goal_Eular_[0] = yaw;
      
      if(depth_flag == 0 && last_depth_flag == 1)
      {
        robotData.flag_enable_thruster_ = false;
      }
      last_depth_flag = depth_flag;
    }
    else
    {
      robotData.flag_enable_thruster_ = false;
    }
    /*
    if(gripper.data == 1)
    {
      gripper_pub.publish(gripper);
    }
    else if(gripper.data == 2)
    {
      gripper_pub.publish(gripper);
    }
    else
    {
      gripper_pub.publish(gripper);
    }
    */

    udpUser_.thread_communication_send();
    udpUser_.thread_communication_rev();

    ros::spinOnce();
    ros::Rate loop_rate(1000); // wrong sleeping interval may cause rotors to fail
  }
  robotData.gimbal_Pitch_ = 0.314; //camera
  robotData.led_brightness_top_ = 0; //LED top
  robotData.led_brightness_bot_ = 0; //LED bot
  udpUser_.thread_communication_send();
  udpUser_.thread_communication_rev();
  printf("Studown!!!\n");

  return 0;
}