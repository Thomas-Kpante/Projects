const BOARD_SIZE = 5
const NUMBER_OF_DIAMONDS = 50

const board = createBoard(NUMBER_OF_DIAMONDS)
const boardElement = document.querySelector(".board")
const diamondLeftText = document.querySelector("[data-diamond-count]")
const piocheLeftText = document.querySelector("[data-pioche-count]")
const messageText = document.querySelector(".subtext")
const diamondStatusText = document.querySelector("[data-diamondStatus-count]")
let diamondCollected = 0;
let piocheleft = 30;
let xUser = 7;
let yUser = 13;
let gameOverStatus = false;
const buttonRestart = document.getElementById("button");


console.log(board)

board.forEach(row => {
  row.forEach(tile => {
    boardElement.append(tile.element)
    })
  })

boardElement.style.setProperty("--size", 25)
diamondLeftText.textContent = diamondCollected
piocheLeftText.textContent = piocheleft







function createBoard(numberOfDiamonds) {
  const board = []

  const DiamondPositions = getDiamondPositions(numberOfDiamonds)


  for (let x = 0; x < 15; x++) {
    const row = []
    for (let y = 0; y < 25; y++) {
      const element = document.createElement("div")
      element.dataset.status = "block"

      if (x == 7 && y == 13){
        element.dataset.status = "user"
      }
      const tile = {
        element,
        x,
        y,
        diamonds: DiamondPositions.some(positionMatch.bind(null, { x, y })),
        get status() {
          return this.element.dataset.status
        },
        set status(value) {
          this.element.dataset.status = "value"
        },
      }
      if(tile.diamonds && tile.element.dataset.status != "user"){
          tile.element.dataset.status = "diamond"
      }
      row.push(tile)
    }
    board.push(row)
  }

  return board
}





function randomNumber(size) {
  return Math.floor(Math.random() * size)
}

function getDiamondPositions(numberOfDiamonds) {
  const positions = []

  while (positions.length < numberOfDiamonds) {
    const position = {
      x: randomNumber(25),
      y: randomNumber(15),
    }

    if (!positions.some(positionMatch.bind(null, position))) {
      positions.push(position)
    }
  }
  return positions
}

function positionMatch(a, b) {
  return a.x === b.x && a.y === b.y
}



document.addEventListener("keydown", function(event){
  // Check for up/down key presses
  if(!gameOverStatus){
  switch(event.keyCode){
    case 37: // Up arrow    
      // Remove the highlighting from the previous element

      if(board[xUser][yUser-1].element.dataset.status == "diamond"){
        diamondCollected++;
        diamondLeftText.textContent = diamondCollected
      }
      board[xUser][yUser-1].element.dataset.status = "user"
      board[xUser][yUser].element.dataset.status = "vide"
      yUser--;
      piocheleft--;
      break;
    case 38: // Up arrow    
      // Remove the highlighting from the previous element
      if(board[xUser-1][yUser].element.dataset.status == "diamond"){
        diamondCollected++;
        diamondLeftText.textContent = diamondCollected
      }
      board[xUser-1][yUser].element.dataset.status = "user"
      board[xUser][yUser].element.dataset.status = "vide"
      xUser--;
      piocheleft--;
      break;
      case 39: // Up arrow    
      // Remove the highlighting from the previous element
      if(board[xUser][yUser+1].element.dataset.status == "diamond"){
        diamondCollected++;
        diamondLeftText.textContent = diamondCollected
      }

      board[xUser][yUser+1].element.dataset.status = "user"
      board[xUser][yUser].element.dataset.status = "vide"
      yUser++;
      piocheleft--;
      break;
    case 40: 
    if(board[xUser+1][yUser].element.dataset.status == "diamond"){
      diamondCollected++;
      diamondLeftText.textContent = diamondCollected
    }
    board[xUser+1][yUser].element.dataset.status = "user"
      board[xUser][yUser].element.dataset.status = "vide"
      xUser++;
      piocheleft--;
      break;    
  }

  piocheLeftText.textContent = piocheleft

  if (piocheleft == 0){
    let gameOver = document.getElementById("game-over");
    gameOver.style.display = "block";
    gameOverStatus = true;
    diamondStatusText.textContent = diamondCollected + " cristaux reçu"
    buttonRestart.addEventListener("click", refresh);
``
    
    }
}});

function refresh(){
  window.location.reload();

}

