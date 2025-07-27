import sys
import numpy as np
import cv2

cap  = cv2.VideoCapture(0)
face_cascade =cv2.CascadeClassifier('C:\\Users\\omkar\\pranav\\Python\\AI Projects\\RealTime_face_detection\\haarcascade_frontalface_alt.xml')
face_data = []
skip =0 
face_dir ='C:\\Users\\omkar\\pranav\\Python\\AI Projects\\RealTime_face_detection\\face_data\\'

if len(sys.argv) < 2:
    print("Error: No user name provided!")
    sys.exit(1)

file_name = sys.argv[1]

while True:
    ret ,frame = cap.read()
    if ret == False:
        continue
    gray_frame = cv2.cvtColor(frame,cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray_frame,1.5,5)
    if len(faces) == 0:
        continue

    k=1
    faces = sorted(faces,key=lambda x:x[2]*x[3],reverse=True)
    skip +=1

    for face in faces[:1]:
        x,y,w,h = face
        offset = 5
        frame_offset = frame[y-offset:y+h+offset,x-offset:x+w+offset]
        face_selection = cv2.resize(frame_offset,(100,100))

        if skip % 10 == 0:
            face_data.append(face_selection)
            print(len(face_data))
            print('skip=',skip)

        cv2.imshow(str(k),face_selection)
        k +=1
        cv2.rectangle(frame,(x,y),(x+w,y+h),(0,255,0),2)

    


        cv2.imshow('face Scanning',frame)

    if cv2.waitKey(1) &0xff == ord('q'):
        break

face_data =  np.array(face_data)
face_data = face_data.reshape((face_data.shape[0],-1))
print(face_data)

np.save(face_dir+file_name,face_data)
print('Dataset saved at:{}'.format(face_dir +file_name+'.npy'))
cap.release()
cv2.destroyAllWindows()