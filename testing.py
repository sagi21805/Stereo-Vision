
import cv2
# open video0
cap = cv2.VideoCapture(0)
cap.grab()
cap2 = cv2.VideoCapture(2)
cap2.grab()
# Turn on auto exposure
cap.set(cv2.CAP_PROP_AUTO_EXPOSURE, 3)
# # set exposure time
cap.set(cv2.CAP_PROP_EXPOSURE, 1000)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)


cap2.set(cv2.CAP_PROP_AUTO_EXPOSURE, 3)
# # set exposure time
cap2.set(cv2.CAP_PROP_EXPOSURE, 1000)
cap2.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap2.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

# while(True):
#     # Capture frame-by-frame
#     ret, frame = cap.read()
#     ret2, frame2 = cap2.read()
#     # Display the resulting frame
#     cv2.imshow('frame', frame)
#     cv2.imshow('frame2',frame2) 
#     if cv2.waitKey(1) & 0xFF == ord('q'):
#         break
