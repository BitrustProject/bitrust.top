var placeLetterInterval = 500;
var placeLetterTimer, moveLettersTimer;
var startButton, resetButton;
var box, message, score,congra,level;
var speed = 5;
var speedbase = 5;
var hits = 0;

function placeLetter() {
    var letter = String.fromCharCode(97 + Math.floor(Math.random() * 26));
    var newLetter = document.createElement("div");
    newLetter.innerHTML = letter;
    newLetter.className = letter;

    newLetter.style.top = Math.random() * 300 + "px";
    newLetter.style.right = 1000 + "px";

    box.appendChild(newLetter);
}

function moveLetters() {
    var boxes = document.querySelectorAll("#box > div");
    for (var i = 0; i < boxes.length; i++) {
        boxes[i].style.right = parseInt(boxes[i].style.right) - speed + "px";
        if (parseInt(boxes[i].style.right) <= -10) {
            endGame();
        }
    }
}

function decreaseLetterSpeed(score) {

}

function endGame() {
    clearInterval(moveLettersTimer);
    clearInterval(placeLetterTimer);
    document.removeEventListener('keydown', keyboardInput);
    if(hits >=100)
       congra.classList.remove("hidden");
    else
       message.classList.remove("hidden");
    resetButton.classList.remove("disabled")
}


function resetGame() {
    message.classList.add("hidden");
    congra.classList.add("hidden");
    resetButton.classList.add("disabled")
    score.innerHTML = 0;
    level.innerHTML = 1;
    hits = 0;
    speed = speedbase;
    var boxes = document.querySelectorAll("#box > div");
    for (var i = 0; i < boxes.length; i++) {
        boxes[i].remove();
    }

    startGame();
}

function keyboardInput() {
    if (event.keyCode === 27) {
        return endGame();
    };

    var key = String.fromCharCode(event.keyCode).toLowerCase();
    var boxes = document.getElementsByClassName(key);

    if (boxes[0]) {
        boxes[0].remove();
        score.innerHTML = parseInt(score.innerHTML) + 1;
        decreaseLetterSpeed(score);
        hits ++;
        var lv = Math.floor(hits/10+1);
        level.innerHTML = lv;
        speed = lv*speedbase; 
    } else {
        hits --;
        score.innerHTML = parseInt(score.innerHTML) - 1;
    }

}


function startGame() {
    placeLetterTimer = setInterval(placeLetter, placeLetterInterval);
    moveLettersTimer = setInterval(moveLetters, 100);
    document.addEventListener('keydown', keyboardInput);
    startButton.classList.add("disabled");
}

document.addEventListener("DOMContentLoaded", function(event) {
    console.log("OH HAI THERE!");

    message = document.getElementById('message');
    congra = document.getElementById('congra');
    box = document.getElementById('box');
    score = document.getElementById("score");
level = document.getElementById("level");

    startButton = document.getElementById('start')
    startButton.onclick = startGame;

    resetButton = document.getElementById('reset')
    resetButton.onclick = resetGame;
});
