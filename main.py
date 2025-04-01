
import sys
from tkinter import Button, Entry, Label, StringVar, Text, Tk

from face_detection import DetectFace, PresentyPage
from tkinter import *
import subprocess
import subprocess
from tkinter import *


def greet(s):
    print(s)

    


def register():
    regPage = Toplevel()
    regPage.title("Registration Page")
    regPage.geometry("400x400")
    regPage.configure(bg="#f0f0f0")

    Label(regPage, text="Registration Page", font=("Times New Roman", 30), bg="#f0f0f0").pack(pady=10)

    Label(regPage, text="Enter Name:", bg="#f0f0f0", font=("Arial", 20)).pack(pady=5)
    name_var = StringVar()
    name_entry = Entry(regPage, textvariable=name_var, width=30)
    name_entry.pack(pady=5)

    def submit():
        name = name_var.get().strip() 
        if not name:
            Label(regPage, text="Error: Name cannot be empty!", fg="red", bg="#f0f0f0").pack(pady=5)
            return

        print(f"Running command: python face_collection.py {name}") 
        subprocess.run(["python", "face_collection.py", name])

        Label(regPage, text="Registration Successful!", fg="green", bg="#f0f0f0").pack(pady=5)

    Button(regPage, text="Submit", command=submit, bg="blue", fg="white").pack(pady=20)

    regPage.mainloop()

# register()

def makeAttendance():
    # with open("face_detection.py") as f:
    DetectFace()
    PresentyPage()
    #     exec(f.read(),globals())
    

def HomePage():
    home = Tk()
    home.title("Home Page")
    home.geometry("500x500")
    home.configure(bg="#f0f0f0")
    label = Label(home, text="STUDENT ATTENDANCE SYSTEM", bg="#f0f0f0",font=("Times New Roman", 20))
    label.pack(pady=20)

    
    Button(text="Register Student", font=("Arial", 20), fg="blue",command=register).pack()

    Button(text="Mark Attendance ",command=makeAttendance, font=("Arial", 20), fg="blue").pack()
   

 
    home.mainloop()


def Database(name):
    DB  = Tk()
    DB.title("Database")
    DB.geometry("500x500")
    Label(text="Database").grid(row=1,column=2)
    Label(text=f"{name} Present").grid(row=2,column=1)

if __name__  =="__main__":
    greet("Welcome User")
    HomePage()
    
