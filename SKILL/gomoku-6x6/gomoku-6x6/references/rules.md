# Gomoku-6x6 Rules and Strategy

## Basic Rules

### Game Setup
- Board: 6x6 grid (36 positions)
- Players: Two players (Black and White, or X and O)
- Black/First player goes first

### Gameplay
- Players alternate turns placing one stone on an empty intersection
- Stones cannot be moved or removed once placed
- Goal: Get exactly 5 stones in a row (horizontally, vertically, or diagonally)

### Win Conditions
- **5 in a row**: Exactly 5 consecutive stones of the same color
- **No 6+**: On a 6x6 board, getting 6 in a row is impossible due to board size
- **Multiple lines**: If a move creates multiple winning lines simultaneously, it still counts as a win

### Special Considerations for 6x6
- The smaller board makes the game more tactical and faster
- Center control is even more critical than in standard Gomoku
- Games typically end much quicker (10-20 moves vs 30+ in standard)

## Strategy Guide

### Opening Principles
1. **Center Control**: The four center squares (positions (2,2), (2,3), (3,2), (3,3) in 0-indexed) are most valuable
2. **Flexibility**: Early moves should create multiple potential threats
3. **Balance**: Don't overextend - keep defensive options open

### Common Patterns
- **Open Four**: Four stones in a row with empty spaces at both ends - forces opponent to block
- **Three-Two**: A three-stone line adjacent to a two-stone line - creates double threat
- **Cross-cut**: Blocking patterns that prevent opponent from extending lines

### Defensive Play
- Always watch for opponent's potential open fours
- Block immediately when opponent has a direct winning threat
- Create your own threats while defending to maintain initiative

## Implementation Notes

### Board Representation
- Use 0-indexed coordinates: (row, col) where both range from 0-5
- Empty = 0, Black/Player1 = 1, White/Player2 = 2

### Win Detection Algorithm
- Check all 4 directions from each placed stone:
  - Horizontal: left/right
  - Vertical: up/down  
  - Diagonal: top-left to bottom-right
  - Anti-diagonal: top-right to bottom-left
- Count consecutive stones in each direction
- Total count = sum of both directions + 1 (the placed stone)
- Win if total count >= 5

### Valid Move Validation
- Check if position is within bounds (0-5 for both coordinates)
- Check if position is empty (value == 0)

## Game Variants

### Standard Gomoku-6x6
- First player to get 5 in a row wins
- No special opening rules needed due to small board size

### Tournament Rules (Optional)
- **Swap2**: Second player can choose to swap colors after first move
- **Time limits**: Useful for competitive play
- **Draw conditions**: If board fills completely with no winner (rare on 6x6)

## Resources
- [Gomoku Wikipedia](https://en.wikipedia.org/wiki/Gomoku)
- [Renju International Federation](https://renju.net/) - Official rules for standard Gomoku
- [6x6 Gomoku Analysis](https://www.renju.net/) - Strategic analysis of smaller boards