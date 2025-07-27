import subprocess
from tkinter import Button, Label, Tk
import cv2
import numpy as np
import os
def distance(v1, v2):
    return np.sqrt(((v1 - v2) ** 2).sum())

def knn(train, test, k=5):
    dist = []
    for i in range(train.shape[0]):
        ix = train[i, :-1] 
        iy = train[i, -1]  
        d = distance(test, ix)
        dist.append([d, iy])
    
    dk = sorted(dist, key=lambda x: x[0])[:k]
    labels = np.array(dk)[:, -1] 
    output = np.unique(labels, return_counts=True)
    index = np.argmax(output[1])
    return int(output[0][index]) 
cascade_path = 'C:\\Users\\omkar\\pranav\\Python\\AI Projects\\RealTime_face_detection\\haarcascade_frontalface_alt.xml'

def DetectFace():
    global name
    if not os.path.exists(cascade_path):
        print("Error: Haar cascade file not found!")
        exit()

    face_cascade = cv2.CascadeClassifier(cascade_path)

    # Load dataset
    dataset_path = 'C:\\Users\\omkar\\pranav\\Python\\AI Projects\\RealTime_face_detection\\face_data\\'
    if not os.path.exists(dataset_path):
        print("Error: Face data directory not found!")
        exit()

    face_data = []
    labels = []
    names = {}
    class_id = 0

    for fx in os.listdir(dataset_path):
        if fx.endswith(".npy"):
            names[class_id] = fx[:-4]
            data_item = np.load(os.path.join(dataset_path, fx))

            if data_item.size == 0:
                print(f"Warning: {fx} is empty, skipping...")
                continue

            face_data.append(data_item)
            target = class_id * np.ones((data_item.shape[0],))
            labels.append(target)
            class_id += 1

    if not face_data or not labels:
        print("Error: No valid face data found!")
        exit()

    face_dataset = np.concatenate(face_data, axis=0)
    face_labels = np.concatenate(labels, axis=0).reshape((-1, 1))
    trainset = np.concatenate((face_dataset, face_labels), axis=1)

    print(f"Dataset loaded: {face_dataset.shape}, Labels: {face_labels.shape}")

    cap = cv2.VideoCapture(0)

    while True:
        ret, frame = cap.read()
        if not ret:
            continue

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

        for x, y, w, h in faces:
            offset = 10
            x1, y1 = max(x - offset, 0), max(y - offset, 0)
            x2, y2 = min(x + w + offset, frame.shape[1]), min(y + h + offset, frame.shape[0])
            
            face_section = frame[y1:y2, x1:x2]
            face_section = cv2.resize(face_section, (100, 100))

            out = knn(trainset, face_section.flatten())

            name = names.get(out, "Unknown") 
            color = (0, 255, 0) if name != "Unknown" else (0, 0, 255)
        

            cv2.putText(frame,name+" are present" if name!="Unknown" else name, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2, cv2.LINE_AA)
            cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)

        cv2.imshow("Face Recognition", frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
def PresentyPage():
    page = Tk()
    page.title("Presenty Page")
    page.geometry("800x600")
    page.configure(bg="#f0f0f0")
    label = Label(page, text="Presenty Page", font=("Arial", 20))
    label2 = Label(page, text=f"{name} are Present", font=("Arial", 20))
    label.pack(pady=20)
    label2.pack(pady=30)
    # Button(text="Continue").pack(pady=90)
    page.mainloop()
# DetectFace()
# PresentyPage()