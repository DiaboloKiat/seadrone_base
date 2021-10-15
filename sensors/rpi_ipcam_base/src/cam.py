#!/usr/bin/env python3
# https://maker.pro/raspberry-pi/projects/raspberry-pi-webcam-robot
# https://osoyoo.com/2020/04/30/install-a-web-camera-on-raspberry-pi/


import rospy
import numpy as np
import cv2
#import mediapipe as mp      # https://google.github.io/mediapipe/solutions/hands.html

from cv_bridge import CvBridge, CvBridgeError
from sensor_msgs.msg import Image, CameraInfo
from std_msgs.msg import String
from utils import CvFpsCalc

def image():
	bridge = CvBridge()
	rospy.init_node("seadrone_image_node", anonymous=True)

	pub_img = rospy.Publisher('/seadrone_image/image', Image, queue_size = 10)
	pub_info = rospy.Publisher('/seadrone_info', CameraInfo, queue_size = 10)
	
	# FPS Measurement
	cv_fps_calc = CvFpsCalc(buffer_len=5)

	cap = cv2.VideoCapture('http://192.168.0.122:8090/?action=stream')
	rate = rospy.Rate(1000) # 1000hz
	print("Start\n")

	while not rospy.is_shutdown():
		fps = cv_fps_calc.get()

		ret, frame = cap.read()
		image = cv2.flip(frame, 1)
		cam_info = CameraInfo()
		cam_info.width = 1280
		cam_info.height = 720
		cam_info.K = [3829.436319, 0.000000, 794.572896, 0.000000, 920.751044, 388.229605, 0.0, 0.0, 1.0]
		cam_info.D = [-0.331206, 0.072907, -0.016254, -0.025161, 0.000000]
		cam_info.R = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]
		cam_info.P = [635.284485, 0.000000, 805.929614, 0.000000, 635.284485, 0.000000, 805.929614, 0.000000, 0.0, 0.0, 1.0, 0.0]
		cam_info.distortion_model = "plumb_bob"
		pub_info.publish(cam_info)
		pub_img.publish(bridge.cv2_to_imgmsg(image, "bgr8"))
		rate.sleep()
		
		cv2.putText(image, "fps:{}".format(fps), (5, 720 - 5), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
		cv2.imshow('seadrone_camera', image)
		cv2.waitKey(3)

	cv2.destroyAllWindows()

if __name__ == "__main__":
	try:
		image()
	except rospy.ROSInterruptException:
		pass


