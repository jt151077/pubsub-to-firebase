/*
# Copyright 2021 Google LLC
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
*/

import { initializeApp } from "https://www.gstatic.com/firebasejs/9.15.0/firebase-app.js";
import { getAuth, signInWithEmailAndPassword } from "https://www.gstatic.com/firebasejs/9.15.0/firebase-auth.js";
import { getFirestore, doc, onSnapshot } from "https://www.gstatic.com/firebasejs/9.15.0/firebase-firestore.js";

const firebaseConfig = {};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

const submitButton = document.getElementById("submit");
const emailInput = document.getElementById("email");
const passwordInput = document.getElementById("password");

var email, password;

/* canvas element init */
const canvas = document.getElementById('trafficlight');
const context = canvas.getContext('2d');
const centerX = canvas.width / 2;
const centerY = canvas.height / 2;
const radius = 70;
context.beginPath();
context.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
context.fillStyle = "#FFFFFF";
context.fill();

submitButton.addEventListener("click", function () {
    email = emailInput.value;
    password = passwordInput.value;

    signInWithEmailAndPassword(auth, email, password)
        .then((userCredential) => {
            // Signed in
            const user = userCredential.user;

            const loginContainer = document.getElementById("login-container");
            const main = document.getElementById("main");
            const installation = document.getElementById("installation");

            loginContainer.style.display = "none";
            main.style.display = "none";
            installation.style.display = "block";
            document.body.style.backgroundColor = "#FFFFFF";

            const db = getFirestore()
            const unsub = onSnapshot(doc(db, "crusher", "status"), (doc) => {
                console.log("Current data: ", doc.data());
                const val = doc.data()['value']
                document.getElementById("val").innerHTML = val;
                const pant = doc.data()['pant']
                document.getElementById("pant").innerHTML = pant;
                var color;

                if (val >= 100) {
                    color = '#FF0000';
                }
                else if (val < 100 && val >= 70) {
                    color = '#D68910';
                }
                else if (val < 70 && val >= 40) {
                    color = '#F1C40F';
                }
                else {
                    color = '#229954';
                }

                context.fillStyle = color;
                context.fill();
            });
        })
        .catch((error) => {
            const errorCode = error.code;
            const errorMessage = error.message;
            console.log("Error occurred. Try again.");
            window.alert("Error occurred. Try again.");
        });
});

// Execute a function when the user presses a key on the keyboard
emailInput.addEventListener("keypress", function (event) {
    // If the user presses the "Enter" key on the keyboard
    if (event.key === "Enter") {
        // Cancel the default action, if needed
        event.preventDefault();
        // Trigger the button element with a click
        submitButton.click();
    }
});

passwordInput.addEventListener("keypress", function (event) {
    // If the user presses the "Enter" key on the keyboard
    if (event.key === "Enter") {
        // Cancel the default action, if needed
        event.preventDefault();
        // Trigger the button element with a click
        submitButton.click();
    }
});