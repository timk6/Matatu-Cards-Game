# Matatu-Cards-Game
Ring prog lang code (1.22) of a Matatu Cards Game  -Developed using Claude ai
## 📖 Screeshots

<table>
  <tr>
    <td align="center">
      <strong>Basic mode</strong><br>
      <img src="screenshots/Capture.JPG" width="300">
    </td>
    <td align="center">
      <img src="screenshots/2Capture.JPG" width="300">
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/3Capture.JPG" width="300">
    </td>
    <td align="center">
      <img src="screenshots/4Capture.JPG" width="300">
    </td>
  </tr>
</table>
# 🃏 About the Matatu Cards Game

**Matatu** is a popular Ugandan card game.  
This implementation was created using **prompt-driven development** with AI assistance.

🔗 Learn more about the traditional game rules:  
https://justafoodblog.com/the-ugandan-matatu-card-game-a-guide-to-playing/

---

## 📜 Game Rules

### 🎯 Objective
Be the **first player to play all your cards**, or when the game is cut, have the **smallest total card value**.

---

## 🟡 Basic Mode

- Play a card on the **discard pile** based on the last card played.
- A card is valid if it matches:
  - **Suit** (e.g. Heart on Heart), or
  - **Value** (e.g. 3 of Spades on 3 of Clubs)
- Cards that match neither suit nor value **cannot be played**.

**Rule of thumb:**  
➡️ *Same suit or same value until someone finishes their cards.*

---

## 🟠 Advanced Mode
*(All Basic Mode rules apply)*

- **Ace (A):** requests a card of **any suit**.
- **Card 7 (Cutter):** ends the game **immediately**.
  - Player with the **lowest total card value wins**.

### Card Values (Advanced Mode)
- Jack = 11  
- Queen = 12  
- King = 13  
- Ace = 15  
- 2 = 20  
- Cards 3–10 = face value  

---

## 🔴 Expert Mode
*(Basic + Advanced rules apply)*

### Penalty Cards
- **2** → opponent picks **2 cards**
- **3** → opponent picks **3 cards**
- Can be countered by:
  - Playing another **2** (any suit)
  - Playing a **3** (same suit)
  - Playing a **Joker**

### Joker Rules
- **Black Joker** → Spades or Clubs  
- **Red Joker** → Diamonds or Hearts  
- Default penalty: **pick 5 cards**
- Counter options reduce the penalty or cancel it.

### Cutter (7)
- Ends the game instantly.
- Player with the **lowest total card value wins**.

### Card Values (Expert Mode)
- Jack = 11  
- Queen = 12  
- King = 13  
- Ace = 15  
- 2 = 20  
- 3 = 30  
- Cards 4–10 = face value  
- Joker = 50  

---

## 🎉 Enjoy!

**k**
