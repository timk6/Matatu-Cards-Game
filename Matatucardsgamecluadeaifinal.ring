/*
** Application  : Matatu Cards Game
** Author       : Tim Kamara (prompt driven development with Claude ai code)
*/


load "guilib.ring"

# Global variables
oPic = NULL
aGameCards = []
oBlankCard = NULL
oBlackJoker = NULL
oRedJoker = NULL
win = NULL
gameArea = NULL
messageLabel = NULL
statusBar = NULL

# Game mode: 0=Basic, 1=Advanced, 2=Expert
nGameMode = 0

# Game state
aDeck = []
aPlayerCards = []
aComputerCards = []
aDiscardPile = []
aCutter = NULL
nCutterSuit = 0
nRequestedSuit = -1
nCurrentPlayer = 1
bGameOver = false
bWaitingForSuitChoice = false

# Expert mode penalty tracking
nPendingDraw = 0  # Number of cards opponent must draw
nLastPenaltyCard = 0  # Track what caused the penalty

# UI elements
aPlayerCardBtns = []
aComputerCardLabels = []
aDiscardLabels = []
aDeckLabel = NULL
aCutterLabel = NULL
drawBtn = NULL
modeBtn = NULL
aceSuitDialog = NULL
aSuitBtns = []

func main
    new qApp {
        win = new qWidget() {
            setWindowTitle("Matatu Card Game - Two Player")
            resize(1000, 696)
            setStyleSheet("background-color: #27ae60;")
            setWinIcon(win,"redjoker.png")
            # Load the cards
            LoadCardsGame()
            
            # Title Label
            titleLabel = new qLabel(win) {
                setText("Matatu CARD GAME - PLAYER VS COMPUTER")
                setAlignment(Qt_AlignHCenter)
                move(200, 10)
                resize(500, 35)
                setStyleSheet("font-size: 18px; font-weight: bold; color: white;")
            }
            
            # Message Label
            messageLabel = new qLabel(win) {
                setText("Click 'New Game' to start!")
                setAlignment(Qt_AlignHCenter)
                move(100, 50)
                resize(800, 25)
                setStyleSheet("font-size: 14px; color: yellow; font-weight: bold;")
            }
            
            # Status Bar
            statusBar = new qLabel(win) {
                setText("Status: Ready to play - BASIC MODE")
                setAlignment(Qt_AlignLeft)
                move(20, 710)
                resize(960, 30)
                setStyleSheet("font-size: 13px; color: white; background-color: #34495e; padding: 5px;")
            }
            
            # Mode Toggle Button
            modeBtn = new qPushButton(win) {
                setText("Mode: BASIC")
                move(20, 10)
                resize(150, 40)
                setStyleSheet("background-color: #9b59b6; color: white; font-size: 13px; font-weight: bold;")
                setClickEvent("toggleMode()")
            }

            # ABOUT
            ABOUTBtn = new qPushButton(win) {
                setText("ABOUT")
                move(700, 10)
                resize(120, 40)
                setStyleSheet("background-color: #e74c3c; color: white; font-size: 14px; font-weight: bold;")
                setClickEvent("showRules()")
            }
            
            # New Game Button
            newGameBtn = new qPushButton(win) {
                setText("New Game")
                move(850, 10)
                resize(120, 40)
                setStyleSheet("background-color: #e74c3c; color: white; font-size: 14px; font-weight: bold;")
                setClickEvent("startNewGame()")
            }
            
            # Draw Card Button
            drawBtn = new qPushButton(win) {
                setText("Draw Card")
                move(850, 60)
                resize(120, 40)
                setStyleSheet("background-color: #3498db; color: white; font-size: 14px; font-weight: bold;")
                setClickEvent("drawCard()")
                setEnabled(false)
            }
            
            # Game Area
            gameArea = new qLabel(win) {
                move(20, 85)
                resize(960, 615)
                show()
            }
            
            # Labels in game area
            computerLabel = new qLabel(gameArea) {
                setText("COMPUTER CARDS:")
                move(20, 10)
                resize(200, 20)
                setStyleSheet("font-size: 13px; font-weight: bold; color: white;")
            }
            
            deckLabel = new qLabel(gameArea) {
                setText("DECK:")
                move(280, 180)
                resize(80, 20)
                setStyleSheet("font-size: 13px; font-weight: bold; color: white;")
            }
            
            cutterLabelText = new qLabel(gameArea) {
                setText("CUTTER:")
                move(430, 180)
                resize(80, 20)
                setStyleSheet("font-size: 13px; font-weight: bold; color: white;")
            }
            
            discardLabel = new qLabel(gameArea) {
                setText("DISCARD:")
                move(600, 180)
                resize(100, 20)
                setStyleSheet("font-size: 13px; font-weight: bold; color: white;")
            }
            
            playerLabel = new qLabel(gameArea) {
                setText("YOUR CARDS:")
                move(20, 420)
                resize(200, 20)
                setStyleSheet("font-size: 13px; font-weight: bold; color: white;")
            }
            
            show()
        }
        exec()
    }



func LoadCardsGame
    # Load the sprite sheet image
    oPic = new QPixmap("cards.jpg")
    
    if oPic.isNull()
        see "Error: Could not load cards.jpg" + nl
        return
    ok
    
    aGameCards = []
    
    # Load only 52 playing cards (4 suits x 13 cards)
    for x1 = 0 to 3
        for y1 = 0 to 12
            temppic = oPic.copy((79*y1)+1,(124*x1)+1,79,124)
            aGameCards + temppic
        next
    next
    
    # Load blank card separately
    oBlankCard = oPic.copy(1,(124*4)+1,79,124)
    
    # Load joker cards for Expert mode
    oBlackJoker = new QPixmap("blackjoker.png")
    oRedJoker = new QPixmap("redjoker.png")
    
    # If joker images don't exist, create placeholders
    if oBlackJoker.isNull()
        see "Warning: blackjoker.png not found, using placeholder" + nl
        oBlackJoker = oBlankCard
    ok
    
    if oRedJoker.isNull()
        see "Warning: redjoker.png not found, using placeholder" + nl
        oRedJoker = oBlankCard
    ok
    
    nTotalCards = len(aGameCards)
    see "Cards loaded successfully! Total cards: " + nTotalCards + nl

func toggleMode
    nGameMode = (nGameMode + 1) % 3
    
    if nGameMode = 0
        modeBtn.setText("Mode: BASIC")
        statusBar.setText("Status: Switched to BASIC MODE - Start a new game!")
        messageLabel.setText("Basic Mode: Simple suit/value matching only")
    but nGameMode = 1
        modeBtn.setText("Mode: ADVANCED")
        statusBar.setText("Status: Switched to ADVANCED MODE - Start a new game!")
        messageLabel.setText("Advanced Mode: Includes Cutter, Ace powers, and 7-cut rule!")
    else
        modeBtn.setText("Mode: EXPERT")
        statusBar.setText("Status: Switched to EXPERT MODE - Start a new game!")
        messageLabel.setText("Expert Mode: Dog rules, Jokers, and enhanced penalties!")
    ok

func startNewGame
    # Reset game state
    bGameOver = false
    aPlayerCards = []
    aComputerCards = []
    aDiscardPile = []
    aDeck = []
    aCutter = NULL
    nCutterSuit = 0
    nRequestedSuit = -1
    nCurrentPlayer = 1
    bWaitingForSuitChoice = false
    nPendingDraw = 0
    nLastPenaltyCard = 0
    
    # Clear UI
    clearGameUI()
    
    # Create deck (1-52 for basic/advanced, 1-54 for expert with jokers)
    for i = 1 to 52
        aDeck + i
    next
    
    # Expert mode: Add jokers (card indices 53 and 54)
    if nGameMode = 2
        aDeck + 53  # Black Joker
        aDeck + 54  # Red Joker
    ok
    
    # Shuffle deck
    shuffleDeck()
    
    # Deal 7 cards to each player
    for i = 1 to 7
        aPlayerCards + aDeck[1]
        del(aDeck, 1)
        
        aComputerCards + aDeck[1]
        del(aDeck, 1)
    next
    
    # Advanced/Expert mode: Draw cutter card
    if nGameMode >= 1
        aCutter = aDeck[1]
        del(aDeck, 1)
        
        # Make sure cutter is not a joker
        while isJoker(aCutter) and len(aDeck) > 0
            aDeck + aCutter
            shuffleDeck()
            aCutter = aDeck[1]
            del(aDeck, 1)
        end
        
        nCutterSuit = getSuit(aCutter)
        nCutterValue = getCardValue(aCutter)
        
        see "Cutter card: " + getCardName(aCutter) + nl
        
        # Check if cutter is a 7
        if nCutterValue = 7
            messageLabel.setText("Cutter is a 7! Game ends immediately. Counting points...")
            statusBar.setText("Status: Game ended - Cutter was a 7")
            
            aDiscardPile + aCutter
            
            endGameByCut()
            displayGame()
            return
        ok
    ok
    
    # Start discard pile with first card
    aDiscardPile + aDeck[1]
    del(aDeck, 1)
    
    # Display game
    displayGame()
    
    if nGameMode = 0
        messageLabel.setText("Your turn! Play a card or draw from deck.")
        statusBar.setText("Status: Basic Game started - Your turn")
    but nGameMode = 1
        messageLabel.setText("Advanced Mode! Your turn - Watch for 7s and Aces!")
        statusBar.setText("Status: Advanced Game started - Your turn")
    else
        messageLabel.setText("Expert Mode! Dog rules & Jokers active!")
        statusBar.setText("Status: Expert Game started - Your turn")
    ok
    
    drawBtn.setEnabled(true)

func shuffleDeck
    nLen = len(aDeck)
    for i = nLen to 2 step -1
        j = random(i-1) + 1
        temp = aDeck[i]
        aDeck[i] = aDeck[j]
        aDeck[j] = temp
    next

func reshuffleDiscardPile
    # When deck is empty, reshuffle discard pile (except top card) back into deck
    see "=== RESHUFFLING DISCARD PILE ===" + nl
    
    if len(aDiscardPile) <= 1
        see "Cannot reshuffle - only " + len(aDiscardPile) + " card(s) in discard pile" + nl
        return false
    ok
    
    # Keep the top card in discard pile
    topCard = aDiscardPile[len(aDiscardPile)]
    
    # Move all other cards to deck
    nDiscardLen = len(aDiscardPile)
    for i = 1 to nDiscardLen - 1
        aDeck + aDiscardPile[i]
    next
    
    see "Moved " + (nDiscardLen - 1) + " cards from discard to deck" + nl
    
    # Clear discard pile and put top card back
    aDiscardPile = []
    aDiscardPile + topCard
    
    # Shuffle the new deck
    shuffleDeck()
    
    see "Deck now has " + len(aDeck) + " cards" + nl
    see "Discard pile has " + len(aDiscardPile) + " card (top card preserved)" + nl
    
    return true

func displayGame
    clearGameUI()
    
    # Display cutter card (Advanced/Expert mode only)
    if nGameMode >= 1 and aCutter != NULL
        aCutterLabel = new qLabel(gameArea) {
            setPixmap(aGameCards[aCutter])
            move(440, 210)
            resize(79, 124)
            show()
        }
        
        suitNames = ["♣", "♦", "♥", "♠"]
        cutterInfo = new qLabel(gameArea) {
            setText(suitNames[nCutterSuit+1])
            move(440, 340)
            resize(79, 20)
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 14px; font-weight: bold; color: white;")
            show()
        }
    ok
    
    # Display deck
    if len(aDeck) > 0
        xDeckPos = 290
        
        aDeckLabel = new qLabel(gameArea) {
            setPixmap(oBlankCard)
            move(xDeckPos, 210)
            resize(79, 124)
            show()
        }
        
        deckCount = new qLabel(gameArea) {
            setText("" + len(aDeck))
            move(xDeckPos, 340)
            resize(79, 20)
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 12px; font-weight: bold; color: white;")
            show()
        }
    ok
    
    # Display top discard card

    if len(aDiscardPile) > 0

        topCard = aDiscardPile[len(aDiscardPile)]
        
        xDiscardPos = 610
        
        # Display appropriate card image
        cardPixmap = NULL
        if isJoker(topCard)
            if topCard = 53
                cardPixmap = oBlackJoker
            else
                cardPixmap = oRedJoker
            ok
        else
            cardPixmap = aGameCards[topCard]
        ok
        
        discardCardLabel = new qLabel(gameArea) {
            setPixmap(cardPixmap)
            move(xDiscardPos, 210)
            resize(79, 124)
            show()
        }
        aDiscardLabels + discardCardLabel
        
        cardNameLabel = new qLabel(gameArea) {
            setText(getCardName(topCard))
            move(xDiscardPos - 50, 340)
            resize(180, 20)
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 11px; font-weight: bold; color: white;")
            show()
        }
        aDiscardLabels + cardNameLabel
    ok

    # Display pending draw penalty (Expert mode)
    if nGameMode = 2 and nPendingDraw > 0
        penaltyLabel = new qLabel(gameArea) {
            setText("PENALTY: Draw " + nPendingDraw + " cards!")
            move(350, 365)
            resize(300, 25)
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 14px; font-weight: bold; color: #e74c3c; background-color: #f39c12;")
            show()
        }
        aDiscardLabels + penaltyLabel
    ok
    
    # Display computer cards (face down)
    for i = 1 to len(aComputerCards)
        xPos = 20 + ((i-1) * 85)
        
        compCard = new qLabel(gameArea) {
            setPixmap(oBlankCard)
            move(xPos, 40)
            resize(79, 124)
            show()
        }
        aComputerCardLabels + compCard
    next
    
    if len(aComputerCards) > 0
        compCount = new qLabel(gameArea) {
            setText("Computer: " + len(aComputerCards) + " cards")
            move(20, 170)
            resize(150, 20)
            setStyleSheet("font-size: 12px; font-weight: bold; color: white;")
            show()
        }
        aComputerCardLabels + compCount
    ok
    
    # Display player cards (clickable)
    for i = 1 to len(aPlayerCards)
        xPos = 20 + ((i-1) * 85)
        cardIndex = aPlayerCards[i]
        
        # Get appropriate card image
        cardPixmap = NULL
        if isJoker(cardIndex)
            if cardIndex = 53
                cardPixmap = oBlackJoker
            else
                cardPixmap = oRedJoker
            ok
        else
            cardPixmap = aGameCards[cardIndex]
        ok
        
        cardBtn = new qPushButton(gameArea) {
            setIcon(new qIcon(cardPixmap))
            setIconSize(new qSize(79, 124))
            move(xPos, 450)
            resize(79, 124)
            setClickEvent("playCard(" + i + ")")
            setStyleSheet("border: 2px solid #f39c12; background-color: transparent;")
            setToolTip(getCardName(cardIndex))
            show()
        }
        aPlayerCardBtns + cardBtn
        
        # Card name below
        cardDebugLabel = new qLabel(gameArea) {
            setText(getCardName(cardIndex))
            move(xPos - 10, 580)
            resize(100, 15)
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 9px; color: white;")
            show()
        }
        aPlayerCardBtns + cardDebugLabel
    next
    
    if len(aPlayerCards) > 0
        playerCount = new qLabel(gameArea) {
            setText("You: " + len(aPlayerCards) + " cards")
            move(20, 600)
            resize(150, 20)
            setStyleSheet("font-size: 12px; font-weight: bold; color: white;")
            show()
        }
        aPlayerCardBtns + playerCount
    ok

func clearGameUI
    for btn in aPlayerCardBtns
        btn.close()
    next
    aPlayerCardBtns = []
    
    for lbl in aComputerCardLabels
        lbl.close()
    next
    aComputerCardLabels = []
    
    for lbl in aDiscardLabels
        lbl.close()
    next
    aDiscardLabels = []
    
    if aDeckLabel != NULL
        aDeckLabel.close()
        aDeckLabel = NULL
    ok
    
    if aCutterLabel != NULL
        aCutterLabel.close()
        aCutterLabel = NULL
    ok
    
    if aceSuitDialog != NULL
        aceSuitDialog.close()
        aceSuitDialog = NULL
    ok
    
    for btn in aSuitBtns
        btn.close()
    next
    aSuitBtns = []

func isJoker(cardIndex)
    return cardIndex = 53 or cardIndex = 54

func getCardName(cardIndex)
    if cardIndex = 53
        return "Black Joker"
    but cardIndex = 54
        return "Red Joker"
    ok
    
    value = getCardValue(cardIndex)
    suit = getSuit(cardIndex)
    
    valueName = ""
    if value = 1
        valueName = "Ace"
    but value = 11
        valueName = "Jack"
    but value = 12
        valueName = "Queen"
    but value = 13
        valueName = "King"
    else
        valueName = "" + value
    ok
    
    suitNames = ["Clubs", "Diamonds", "Hearts", "Spades"]
    
    return valueName + " of " + suitNames[suit+1]

func playCard(cardPos)
    if bGameOver return ok
    if nCurrentPlayer != 1 return ok
    if bWaitingForSuitChoice return ok
    
    cardIndex = aPlayerCards[cardPos]
    topCard = aDiscardPile[len(aDiscardPile)]
    cardName = getCardName(cardIndex)
    
    see "Player attempting to play: " + cardName + nl
    
    # Expert mode: Check if can counter penalty
    if nGameMode = 2 and nPendingDraw > 0
        if canCounterPenalty(cardIndex, nLastPenaltyCard)
            # Counter successful
            del(aPlayerCards, cardPos)
            aDiscardPile + cardIndex
            
            handlePenaltyCounter(cardIndex, nLastPenaltyCard)
            return
        else
            # Must draw penalty cards
            messageLabel.setText("You must draw " + nPendingDraw + " cards or play a counter card!")
            statusBar.setText("Status: Cannot play " + cardName + " - Must handle penalty first!")
            return
        ok
    ok
    
    # Check if card can be played
    if canPlayCard(cardIndex, topCard)
        see "Card is playable!" + nl
        
        # Remove from player hand
        del(aPlayerCards, cardPos)
        
        # Add to discard pile
        aDiscardPile + cardIndex
        
        # Reset requested suit
        nRequestedSuit = -1
        
        statusBar.setText("Status: You played " + cardName)
        
        # Check if player won
        if len(aPlayerCards) = 0
            messageLabel.setText("YOU WIN! You played all your cards!")
            statusBar.setText("Status: YOU WIN!")
            bGameOver = true
            drawBtn.setEnabled(false)
            displayGame()
            return
        ok
        
        # Advanced/Expert mode: Check for 7 cut
        if nGameMode >= 1
            cardValue = getCardValue(cardIndex)
            cardSuit = getSuit(cardIndex)
            
            if cardValue = 7 and cardSuit = nCutterSuit
                messageLabel.setText("You cut the game with a 7! Counting points...")
                statusBar.setText("Status: You cut the game with " + cardName)
                endGameByCut()
                displayGame()
                return
            ok
        ok
        
        # Expert mode: Apply dog rules and joker penalties
        if nGameMode = 2
            applyPenalty(cardIndex)
        ok
        
        # Advanced/Expert mode: Check for Ace
        if nGameMode >= 1 and getCardValue(cardIndex) = 1
            see "Ace played! Showing suit dialog..." + nl
            bWaitingForSuitChoice = true
            messageLabel.setText("You played an Ace! Choose a suit...")
            statusBar.setText("Status: Waiting for suit choice...")
            displayGame()
            showAceSuitDialog()
            return
        ok
        
        messageLabel.setText("Card played! Computer's turn...")
        displayGame()
        
        # Computer's turn
        nCurrentPlayer = 2
        computerTurn()
    else
        see "Card NOT playable!" + nl
        statusBar.setText("Status: " + cardName + " is not playable!")
        suitNames = ["Clubs", "Diamonds", "Hearts", "Spades"]
        topSuit = getSuit(topCard)
        topValue = getCardValue(topCard)
        messageLabel.setText("Invalid! Need same suit (" + suitNames[topSuit+1] + ") or same value (" + topValue + ")")
    ok

func applyPenalty(cardIndex)
    cardValue = getCardValue(cardIndex)
    cardSuit = getSuit(cardIndex)
    
    # Dog1 rule: 2 forces opponent to draw 2
    if cardValue = 2
        nPendingDraw = 2
        nLastPenaltyCard = cardIndex
        messageLabel.setText("DOG1! Computer must draw 2 or counter!")
        statusBar.setText("Status: Played 2 - Opponent draws 2!")
    ok
    
    # Dog2 rule: 3 forces opponent to draw 3
    if cardValue = 3
        nPendingDraw = 3
        nLastPenaltyCard = cardIndex
        messageLabel.setText("DOG2! Computer must draw 3 or counter!")
        statusBar.setText("Status: Played 3 - Opponent draws 3!")
    ok
    
    # Joker rule: forces opponent to draw 5
    if isJoker(cardIndex)
        nPendingDraw = 5
        nLastPenaltyCard = cardIndex
        messageLabel.setText("JOKER! Computer must draw 5 or counter!")
        statusBar.setText("Status: Played Joker - Opponent draws 5!")
    ok

func canCounterPenalty(counterCard, penaltyCard)
    counterValue = getCardValue(counterCard)
    counterSuit = getSuit(counterCard)
    penaltyValue = getCardValue(penaltyCard)
    penaltySuit = getSuit(penaltyCard)
    
    # Joker can counter anything
    if isJoker(counterCard)
        return true
    ok
    
    # If penalty was from Joker
    if isJoker(penaltyCard)
        # Can counter with 2 or 3 of same color
        # Black Joker (53) = Spades/Clubs (2,3)
        # Red Joker (54) = Diamonds/Hearts (0,1)
        if penaltyCard = 53  # Black Joker
            if (counterSuit = 0 or counterSuit = 3) and (counterValue = 2 or counterValue = 3)
                return true
            ok
        but penaltyCard = 54  # Red Joker
            if (counterSuit = 1 or counterSuit = 2) and (counterValue = 2 or counterValue = 3)
                return true
            ok
        ok
        return false
    ok
    
    # If penalty was from 2
    if penaltyValue = 2
        # Can counter with any 2
        if counterValue = 2
            return true
        ok
        # Or 3 of same suit
        if counterValue = 3 and counterSuit = penaltySuit
            return true
        ok
        return false
    ok
    
    # If penalty was from 3
    if penaltyValue = 3
        # Can counter with any 3
        if counterValue = 3
            return true
        ok
        # Or 2 of same suit (but still draw 1)
        if counterValue = 2 and counterSuit = penaltySuit
            return true
        ok
        return false
    ok
    
    return false

func handlePenaltyCounter(counterCard, penaltyCard)
    counterValue = getCardValue(counterCard)
    penaltyValue = getCardValue(penaltyCard)
    
    # If countered with Joker
    if isJoker(counterCard)
        # Penalty passes to opponent
        messageLabel.setText("You countered with Joker! Computer must draw " + nPendingDraw + "!")
        statusBar.setText("Status: Joker counter - Penalty passed!")
        displayGame()
        nCurrentPlayer = 2
        computerTurn()
        return
    ok
    
    # If penalty was Joker, countered with 2 or 3
    if isJoker(penaltyCard)
        if counterValue = 2
            # Draw 3 instead of 5
            drawMultipleCards(3, 1)
            nPendingDraw = 0
            nLastPenaltyCard = 0
            messageLabel.setText("You drew 3 cards (countered with 2). Computer's turn...")
            statusBar.setText("Status: Partial counter - Drew 3 cards")
        but counterValue = 3
            # Draw 2 instead of 5
            drawMultipleCards(2, 1)
            nPendingDraw = 0
            nLastPenaltyCard = 0
            messageLabel.setText("You drew 2 cards (countered with 3). Computer's turn...")
            statusBar.setText("Status: Partial counter - Drew 2 cards")
        ok
        displayGame()
        nCurrentPlayer = 2
        computerTurn()
        return
    ok
    
    # If penalty was 2
    if penaltyValue = 2
        if counterValue = 2
            # Add penalties
            nPendingDraw += 2
            nLastPenaltyCard = counterCard
            messageLabel.setText("You countered! Computer must now draw " + nPendingDraw + "!")
            statusBar.setText("Status: Counter successful - Penalty increased!")
        but counterValue = 3
            # Full counter
            nPendingDraw = 0
            nLastPenaltyCard = 0
            messageLabel.setText("You countered with 3! No penalty. Computer's turn...")
            statusBar.setText("Status: Full counter - No penalty!")
        ok
    ok
    
    # If penalty was 3
    if penaltyValue = 3
        if counterValue = 3
            # Add penalties
            nPendingDraw += 3
            nLastPenaltyCard = counterCard
            messageLabel.setText("You countered! Computer must now draw " + nPendingDraw + "!")
            statusBar.setText("Status: Counter successful - Penalty increased!")
        but counterValue = 2
            # Draw 1 instead of 3
            drawMultipleCards(1, 1)
            nPendingDraw = 0
            nLastPenaltyCard = 0
            messageLabel.setText("You drew 1 card (countered with 2). Computer's turn...")
            statusBar.setText("Status: Partial counter - Drew 1 card")
        ok
    ok
    
    displayGame()
    nCurrentPlayer = 2
    computerTurn()

func drawMultipleCards(count, player)
    for i = 1 to count
        if len(aDeck) = 0
            exit
        ok
        
        drawnCard = aDeck[1]
        del(aDeck, 1)
        
        if player = 1
            aPlayerCards + drawnCard
        else
            aComputerCards + drawnCard
        ok
    next

func showAceSuitDialog
    suitNames = ["Clubs", "Diamonds", "Hearts", "Spades"]
    suitSymbols = ["♣", "♦", "♥", "♠"]
    
    see "Creating Ace suit selection dialog..." + nl
    
    # Clear any existing dialog
    if aceSuitDialog != NULL
        aceSuitDialog.close()
        aceSuitDialog = NULL
    ok
    
    for btn in aSuitBtns
        btn.close()
    next
    aSuitBtns = []
    
    # Create new dialog
    new qWidget() {
        aceSuitDialog = self
        setParent(win)
        setWindowFlags(Qt_Dialog | Qt_WindowStaysOnTopHint)
        move(260, 300)
        resize(480, 220)
        setStyleSheet("background-color: #34495e; border: 3px solid #f39c12;")
        
        titleLbl = new qLabel(aceSuitDialog) {
            setText("You played an ACE! Choose a suit:")
            move(10, 10)
            resize(460, 30)
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 16px; font-weight: bold; color: white;")
            show()
        }
        
        # Four suit selection buttons with face-down cards
        for i = 0 to 3
            xPos = 10 + (i * 120)
            
            # Face down card image
            faceDownCard = new qLabel(aceSuitDialog) {
                setPixmap(oBlankCard)
                move(xPos + 20, 50)
                resize(79, 124)
                show()
            }
            
            # Suit name label under card
            suitNameLabel = new qLabel(aceSuitDialog) {
                setText(suitNames[i+1])
                move(xPos, 175)
                resize(115, 20)
                setAlignment(Qt_AlignHCenter)
                setStyleSheet("font-size: 11px; font-weight: bold; color: white;")
                show()
            }
            
            # Suit button below
            suitBtn = new qPushButton(aceSuitDialog) {
                setText(suitSymbols[i+1] + " Select")
                move(xPos + 10, 195)
                resize(95, 25)
                
                if i = 0 or i = 3
                    setStyleSheet("backgroun-color: #2d3436; color: white; font-size: 11px; font-weight: bold;")
else
setStyleSheet("background-color: #ff6b6b; color: white; font-size: 11px; font-weight: bold;")
ok


setClickEvent("chooseSuit(" + i + ")")
            show()
        }
        
        aSuitBtns + suitBtn
    next
    
    show()
    raise()
    activateWindow()
}

see "Ace dialog created and shown!" + nl

func chooseSuit(suit)
suitNames = ["Clubs", "Diamonds", "Hearts", "Spades"]

see "Player chose suit: " + suitNames[suit+1] + nl

nRequestedSuit = suit
bWaitingForSuitChoice = false

# Close dialog
if aceSuitDialog != NULL
    aceSuitDialog.close()
    aceSuitDialog = NULL
ok

for btn in aSuitBtns
    btn.close()
next
aSuitBtns = []

messageLabel.setText("You requested " + suitNames[suit+1] + ". Computer's turn...")
statusBar.setText("Status: You requested " + suitNames[suit+1])

displayGame()

# Computer's turn
nCurrentPlayer = 2
computerTurn()

func canPlayCard(cardIndex, topCard)
cardSuit = getSuit(cardIndex)
cardValue = getCardValue(cardIndex)
topSuit = getSuit(topCard)
topValue = getCardValue(topCard)

# Joker rules (Expert mode)
if nGameMode = 2
    # If playing a Joker card
    if isJoker(cardIndex)
        # Black Joker can be played on Spades or Clubs
        if cardIndex = 53
            return topSuit = 0 or topSuit = 3
        ok
        
        # Red Joker can be played on Diamonds or Hearts
        if cardIndex = 54
            return topSuit = 1 or topSuit = 2
        ok
    ok
    
    # If the top card is a Joker (playing a regular card ON a joker)
    if isJoker(topCard)
        cardSuit = getSuit(cardIndex)
        
        # Black Joker on top: Can play Clubs (0) or Spades (3)
        if topCard = 53
            return cardSuit = 0 or cardSuit = 3
        ok
        
        # Red Joker on top: Can play Diamonds (1) or Hearts (2)
        if topCard = 54
            return cardSuit = 1 or cardSuit = 2
        ok
    ok
ok

# Advanced/Expert mode: Ace can be played on anything
if nGameMode >= 1 and cardValue = 1
    return true
ok

# If suit was requested by Ace
if nRequestedSuit >= 0
    if cardSuit = nRequestedSuit
        return true
    ok
    return false
ok

# Rule 1: Same suit
if cardSuit = topSuit
    return true
ok

# Rule 2: Same value
if cardValue = topValue
    return true
ok

return false

func getSuit(cardIndex)
# Jokers don't have a suit
if isJoker(cardIndex)
return -1
ok

suit = ((cardIndex - 1) / 13)

if suit >= 0 and suit < 1
    return 0  # Clubs
but suit >= 1 and suit < 2
    return 1  # Diamonds
but suit >= 2 and suit < 3
    return 2  # Hearts
else
    return 3  # Spades
ok

func getCardValue(cardIndex)
# Jokers have special value
if isJoker(cardIndex)
return 0
ok

pos = ((cardIndex - 1) % 13) + 1
return pos

func drawCard
if bGameOver return ok
if nCurrentPlayer != 1 return ok
if bWaitingForSuitChoice return ok
    # Check if deck is empty
    if len(aDeck) = 0
        see "Deck is empty, attempting to reshuffle discard pile..." + nl
        
        # Try to reshuffle discard pile
        if reshuffleDiscardPile()
            messageLabel.setText("Deck was empty! Reshuffled discard pile.")
            statusBar.setText("Status: Reshuffled " + len(aDeck) + " cards from discard pile")
            displayGame()
        else
            messageLabel.setText("No more cards available to draw!")
            statusBar.setText("Status: Deck and discard pile are empty!")
            return
        ok
    ok

# Expert mode: If there's a pending draw, must draw penalty cards
if nGameMode = 2 and nPendingDraw > 0
    drawMultipleCards(nPendingDraw, 1)
    messageLabel.setText("You drew " + nPendingDraw + " cards. Computer's turn...")
    statusBar.setText("Status: Drew " + nPendingDraw + " penalty cards")
    nPendingDraw = 0
    nLastPenaltyCard = 0
    displayGame()
    nCurrentPlayer = 2
    computerTurn()
    return
ok

if len(aDeck) = 0
    messageLabel.setText("No more cards in deck!")
    statusBar.setText("Status: Deck is empty!")
    return
ok

# Draw card
drawnCard = aDeck[1]
del(aDeck, 1)
aPlayerCards + drawnCard

cardName = getCardName(drawnCard)
topCard = aDiscardPile[len(aDiscardPile)]

if canPlayCard(drawnCard, topCard)
    messageLabel.setText("Drew a playable card! You can play it now.")
    statusBar.setText("Status: You drew " + cardName + " (playable)")
    displayGame()
else
    messageLabel.setText("Drew a card that can't be played. Computer's turn...")
    statusBar.setText("Status: You drew " + cardName + " (not playable)")
    displayGame()
    nCurrentPlayer = 2
    computerTurn()
ok

func computerTurn
if bGameOver return ok

topCard = aDiscardPile[len(aDiscardPile)]

# Expert mode: Handle penalty
if nGameMode = 2 and nPendingDraw > 0
    # Try to counter
    bCanCounter = false
    counterCardPos = 0
    
    for i = 1 to len(aComputerCards)
        if canCounterPenalty(aComputerCards[i], nLastPenaltyCard)
            bCanCounter = true
            counterCardPos = i
            exit
        ok
    next
    
    if bCanCounter
        # Counter the penalty
        counterCard = aComputerCards[counterCardPos]
        del(aComputerCards, counterCardPos)
        aDiscardPile + counterCard
        
        cardName = getCardName(counterCard)
        statusBar.setText("Status: Computer countered with " + cardName)
        
        # Apply counter logic (similar to player)
        if isJoker(counterCard)
            messageLabel.setText("Computer countered with Joker! You must draw " + nPendingDraw + "!")
            displayGame()
            nCurrentPlayer = 1
            return
        ok
        
        # Handle other counters...
        penaltyValue = getCardValue(nLastPenaltyCard)
        counterValue = getCardValue(counterCard)
        
        if isJoker(nLastPenaltyCard)
            if counterValue = 2
                drawMultipleCards(3, 2)
                messageLabel.setText("Computer drew 3 cards. Your turn...")
            but counterValue = 3
                drawMultipleCards(2, 2)
                messageLabel.setText("Computer drew 2 cards. Your turn...")
            ok
            nPendingDraw = 0
            nLastPenaltyCard = 0
        but penaltyValue = 2
            if counterValue = 2
                nPendingDraw += 2
                nLastPenaltyCard = counterCard
                messageLabel.setText("Computer countered! You must draw " + nPendingDraw + "!")
                displayGame()
                nCurrentPlayer = 1
                return
            but counterValue = 3
                nPendingDraw = 0
                nLastPenaltyCard = 0
                messageLabel.setText("Computer countered. Your turn...")
            ok
        but penaltyValue = 3
            if counterValue = 3
                nPendingDraw += 3
                nLastPenaltyCard = counterCard
                messageLabel.setText("Computer countered! You must draw " + nPendingDraw + "!")
                displayGame()
                nCurrentPlayer = 1
                return
            but counterValue = 2
                drawMultipleCards(1, 2)
                messageLabel.setText("Computer drew 1 card. Your turn...")
                nPendingDraw = 0
                nLastPenaltyCard = 0
            ok
        ok
        
        displayGame()
        nCurrentPlayer = 1
        return
    else
        # Must draw penalty
        drawMultipleCards(nPendingDraw, 2)
        messageLabel.setText("Computer drew " + nPendingDraw + " cards. Your turn...")
        statusBar.setText("Status: Computer drew " + nPendingDraw + " penalty cards")
        nPendingDraw = 0
        nLastPenaltyCard = 0
        displayGame()
        nCurrentPlayer = 1
        return
    ok
ok

# Normal play
bCardPlayed = false

# Try to play a card
for i = 1 to len(aComputerCards)
    cardIndex = aComputerCards[i]
    
    if canPlayCard(cardIndex, topCard)
        # Play card
        del(aComputerCards, i)
        aDiscardPile + cardIndex
        
        cardName = getCardName(cardIndex)
        statusBar.setText("Status: Computer played " + cardName)
        
        # Reset requested suit
        nRequestedSuit = -1
        
        bCardPlayed = true
        
        # Check if computer won
        if len(aComputerCards) = 0
            messageLabel.setText("COMPUTER WINS! Computer played all cards!")
            statusBar.setText("Status: COMPUTER WINS!")
            bGameOver = true
            drawBtn.setEnabled(false)
            displayGame()
            return
        ok
        
        # Advanced/Expert mode: Check for 7 cut
        if nGameMode >= 1
            if getCardValue(cardIndex) = 7 and getSuit(cardIndex) = nCutterSuit
                messageLabel.setText("Computer cut the game with a 7! Counting points...")
                statusBar.setText("Status: Computer cut with " + cardName)
                endGameByCut()
                displayGame()
                return
            ok
        ok
        
        # Expert mode: Apply penalty
        if nGameMode = 2
            applyPenalty(cardIndex)
        ok
        
        # Advanced/Expert mode: Check for Ace
        if nGameMode >= 1 and getCardValue(cardIndex) = 1
            nRequestedSuit = computerChooseSuit()
            suitNames = ["Clubs", "Diamonds", "Hearts", "Spades"]
            messageLabel.setText("Computer played Ace and requests " + suitNames[nRequestedSuit+1] + "!")
            statusBar.setText("Status: Computer requests " + suitNames[nRequestedSuit+1])
            displayGame()
            nCurrentPlayer = 1
            return
        ok
        
        exit
    ok
next

# If no card played, draw from deck
if not bCardPlayed
    if len(aDeck) > 0
        drawnCard = aDeck[1]
        del(aDeck, 1)
        aComputerCards + drawnCard
        
        drawnCardName = getCardName(drawnCard)
        
        # Try to play drawn card
        if canPlayCard(drawnCard, topCard)
            del(aComputerCards, len(aComputerCards))
            aDiscardPile + drawnCard
            
            statusBar.setText("Status: Computer drew and played " + drawnCardName)
            
            # Reset requested suit
            nRequestedSuit = -1
            
            # Check win
            if len(aComputerCards) = 0
                messageLabel.setText("COMPUTER WINS! Computer played all cards!")
                statusBar.setText("Status: COMPUTER WINS!")
                bGameOver = true
                drawBtn.setEnabled(false)
                displayGame()
                return
            ok
            
            # Advanced/Expert mode: Check for 7 cut
            if nGameMode >= 1
                if getCardValue(drawnCard) = 7 and getSuit(drawnCard) = nCutterSuit
                    messageLabel.setText("Computer cut the game with a 7! Counting points...")
                    statusBar.setText("Status: Computer cut with " + drawnCardName)
                    endGameByCut()
                    displayGame()
                    return
                ok
            ok
            
            # Expert mode: Apply penalty
            if nGameMode = 2
                applyPenalty(drawnCard)
            ok
            
            # Advanced/Expert mode: Check for Ace
            if nGameMode >= 1 and getCardValue(drawnCard) = 1
                nRequestedSuit = computerChooseSuit()
                suitNames = ["Clubs", "Diamonds", "Hearts", "Spades"]
                messageLabel.setText("Computer drew Ace and requests " + suitNames[nRequestedSuit+1] + "!")
                statusBar.setText("Status: Computer requests " + suitNames[nRequestedSuit+1])
                displayGame()
                nCurrentPlayer = 1
                return
            ok
        else
            statusBar.setText("Status: Computer drew a card")
        ok
    ok
ok

# Player's turn
nCurrentPlayer = 1
messageLabel.setText("Your turn! Play a card or draw from deck.")
displayGame()

func computerChooseSuit
# Count suits in computer's hand
aSuitCount = [0, 0, 0, 0]

for cardIndex in aComputerCards
    if not isJoker(cardIndex)
        suit = getSuit(cardIndex)
        aSuitCount[suit+1] = aSuitCount[suit+1] + 1
    ok
next

# Find suit with most cards
maxCount = 0
bestSuit = 0

for i = 1 to 4
    if aSuitCount[i] > maxCount
        maxCount = aSuitCount[i]
        bestSuit = i - 1
    ok
next

return bestSuit

func endGameByCut
bGameOver = true
drawBtn.setEnabled(false)

# Calculate points
playerPoints = calculatePoints(aPlayerCards)
computerPoints = calculatePoints(aComputerCards)

resultMsg = "GAME CUT! Your points: " + playerPoints + " | Computer: " + computerPoints + " | "

if playerPoints < computerPoints
    resultMsg += "YOU WIN!"
    statusBar.setText("Status: YOU WIN by " + (computerPoints - playerPoints) + " points!")
but playerPoints > computerPoints
    resultMsg += "COMPUTER WINS!"
    statusBar.setText("Status: COMPUTER WINS by " + (playerPoints - computerPoints) + " points!")
else
    resultMsg += "TIE!"
    statusBar.setText("Status: TIE - Both have " + playerPoints + " points!")
ok

messageLabel.setText(resultMsg)

func calculatePoints(cards)
total = 0

for cardIndex in cards
    if isJoker(cardIndex)
        # Joker = 50 points (Expert mode)
        total += 50
    else
        value = getCardValue(cardIndex)
        
        if value = 1  # Ace
            total += 15
        but value = 2
            if nGameMode = 2
                total += 20  # Expert mode
            else
                total += 20  # Advanced mode
            ok
        but value = 3
            if nGameMode = 2
                total += 30  # Expert mode
            else
                total += 3  # Advanced mode
            ok
        but value >= 4 and value <= 10
            total += value
        but value = 11  # Jack
            total += 11
        but value = 12  # Queen
            total += 12
        but value = 13  # King
            total += 13
        ok
    ok
next

return total

func showRules
    rulesWin = new qWidget() {
        setWindowTitle("Game Rules")
        resize(700, 400)
        move(250, 200)
        
        textEdit = new qTextEdit(rulesWin) {
            setGeometry(10, 10, 680, 380)
            setReadOnly(true)
            setHorizontalScrollBarPolicy(Qt_ScrollBarAsNeeded)
            setVerticalScrollBarPolicy(Qt_ScrollBarAsNeeded)
            
            # Create HTML formatted text
            rulesHTML = '
          <html>
<head>
<meta content="text/html; charset=ISO-8859-1"
http-equiv="content-type">
<title>rules</title>
</head>
<body>
<big style="text-decoration: underline; font-weight: bold;">About the
Matatu-Cards game</big><br>
Created using prompt driven development with Claude ai code.<br>
More details refer to
https://justafoodblog.com/the-ugandan-matatu-card-game-a-guide-to-playing/<br>
<br>
<span style="font-weight: bold; text-decoration: underline;">Rules of
the game</span><br>
<br>
<span
style="color: rgb(204, 153, 51); text-decoration: underline; font-weight: bold;">Basic
mode</span><br>
1. The goal is to be the first player to play all your cards<br>
2. Place a card on the <span
style="font-weight: bold; color: rgb(204, 0, 0);">discard pile</span>
based on the last card that was played. For instance, you can put a <span
style="font-weight: bold; text-decoration: underline;">heart</span> on
another <span style="font-weight: bold; text-decoration: underline;">heart</span>
regardless of the <span
style="font-weight: bold; text-decoration: underline;">number</span> <br>
&nbsp;&nbsp;&nbsp; that is stated on the card. Also, a <span
style="font-weight: bold; text-decoration: underline;">3 of Spades</span>
can be played on a <span
style="font-weight: bold; text-decoration: underline;">3 of Clubs</span>,
but a <span style="font-weight: bold; text-decoration: underline;">5
of spades</span> can not go on a <span
style="font-weight: bold; text-decoration: underline;">9 of diamonds.</span><br>
<big style="text-decoration: underline;"><big><span
style="font-weight: bold;">ie</span></big></big>&nbsp;&nbsp; <span
style="color: rgb(60, 46, 216); font-weight: bold;">cards played
should be same suit or same value Until you finish your cards first</span><br>
<br>
<span
style="color: rgb(204, 153, 51); text-decoration: underline; font-weight: bold;">Advanced
mode</span><br>
<span style="font-weight: bold;">RULES of basic mode hold PLUS</span><br>
1. <span style="font-weight: bold; text-decoration: underline;">Ace
card</span> requests a card of your<big><span style="font-weight: bold;">
choice</span></big><br>
2. <span style="font-weight: bold; text-decoration: underline;">Card
number 7</span> is a <big style="color: red;"><span
style="font-weight: bold;">cutter</span></big> and ends game<span
style="font-weight: bold;"> immediately</span> player with <span
style="font-weight: bold;">smallest total wins</span>, card values are
as follows:<br>
&nbsp;&nbsp;&nbsp; Jack = <span style="font-weight: bold;">11</span>
Points, Queen = <span style="font-weight: bold;">12</span> Points,
King = <span style="font-weight: bold;">13</span> Points, Ace = <span
style="font-weight: bold;">15</span> Points, 2 = <span
style="font-weight: bold;">20</span> Points OTHERS 3 – 10 = <span
style="font-weight: bold;">3 – 10 </span>Points (RESPECTIVELY)<br>
<br>
<span
style="color: rgb(204, 153, 51); text-decoration: underline; font-weight: bold;">Expert
mode</span><br>
<span style="font-weight: bold;">RULES of basic, advanced modes hold
PLUS</span><br>
1. <span style="font-weight: bold; text-decoration: underline;">Card
number 2 and 3</span>&nbsp;&nbsp; are <span
style="font-weight: bold; font-style: italic;">penalty cards</span>, a
player has to pick <span style="font-weight: bold;">2</span> or <span
style="font-weight: bold;">3</span> cards respectively if the other
player plays the mentioned cards <span
style="font-weight: bold; text-decoration: underline;">OR counteract </span><br>
&nbsp; by playing <span
style="font-weight: bold; text-decoration: underline;">2</span> (of
any suite) or <span
style="font-weight: bold; text-decoration: underline;">3</span>&nbsp;
(of same suite) or by playing a <span
style="font-weight: bold; text-decoration: underline;">joker</span> (
blackjoker on spades or clubs, redjoker on diamonds or hearts)<br>
2. <span style="font-weight: bold; text-decoration: underline;">JOKER
cards</span> are <span style="font-weight: bold; font-style: italic;">penalty
cards</span> ( blackjoker can be played on spades or clubs, redjoker on
diamonds or hearts) a player has to pick&nbsp;<span
style="font-weight: bold;"></span> <span style="font-weight: bold;">5</span>
cards if the other <br>
&nbsp;&nbsp;&nbsp; player plays the <span
style="font-weight: bold; text-decoration: underline;">JOKER card</span>
&nbsp; <span style="font-weight: bold; text-decoration: underline;">OR
counteract</span>&nbsp; by playing <span
style="font-weight: bold; text-decoration: underline;">2</span>
(spades or clubs on blackjoker, diamonds or hearts on redjoker)&nbsp;
in this case they pick 3 card <br>
&nbsp;&nbsp;&nbsp; instead of five (5 ) or <span
style="font-weight: bold; text-decoration: underline;">3</span>
(spades or clubs on blackjoker, diamonds or hearts on redjoker)&nbsp;
in this case they pick <span
style="font-weight: bold; text-decoration: underline;">2 </span>card
instead of five (5 ) or by playing the<br>
&nbsp; &nbsp; <span style="font-weight: bold;">remaining joker</span>
card&nbsp; <br>
3. <span style="font-weight: bold; text-decoration: underline;">Card
number 7</span> is a <big style="color: red;"><span
style="font-weight: bold;">cutter</span></big> and ends game<span
style="font-weight: bold;"> immediately</span> player with <span
style="font-weight: bold;">smallest total wins</span>, card values are
as follows:<br>
&nbsp;&nbsp;&nbsp;&nbsp; Jack = <span style="font-weight: bold;">11</span>
Points, Queen = <span style="font-weight: bold;">12</span> Points,
King = <span style="font-weight: bold;">13</span> Points, Ace = <span
style="font-weight: bold;">15</span> Points, 2 = <span
style="font-weight: bold;">20</span> Points, 3= <span
style="font-weight: bold;">30</span> points OTHERS 4 – 10 = <span
style="font-weight: bold;">4 – 10</span> Points (RESPECTIVELY), <br>
&nbsp;&nbsp;&nbsp;&nbsp; joker= <span style="font-weight: bold;">50</span>
points<br>
<br>
<br>
<big style="color: rgb(153, 51, 153);"><big><span
style="font-weight: bold;">ENJOY!!!!</span></big></big><br>
<span style="font-weight: bold; text-decoration: underline;">by Tim
Kamara</span><br>
<br>
</body>
</html>


            '
            
            setHTML(rulesHTML)
        }
        
        show()
    }
return

