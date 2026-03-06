#!/usr/bin/env python3
"""
Gomoku-6x6 飞书五子棋游戏

6x6 棋盘五子棋实现，支持飞书机器人集成。
玩家执 X 先手，AI 执 O 后手（随机落子）。
坐标系统：A1-F6（字母 + 数字）
"""

import random
from typing import Optional, Tuple, List


class Gomoku6x6:
    """6x6 五子棋游戏类"""
    
    # 列字母映射
    COLS = 'ABCDEF'
    
    def __init__(self):
        """初始化游戏"""
        self.board = [[' ' for _ in range(6)] for _ in range(6)]
        self.current_player = 'X'  # 玩家先手
        self.game_over = False
        self.winner: Optional[str] = None
        self.move_history: List[Tuple[int, int, str]] = []
    
    def draw_board(self) -> str:
        """
        绘制 ASCII 棋盘
        
        返回格式化的棋盘字符串，使用 - | + 构成网格
        """
        # 列标题
        header = '  ' + '   '.join(self.COLS) + '\n'
        
        # 上边框
        top_border = '+' + '---+' * 6 + '\n'
        
        rows = []
        for i, row in enumerate(self.board):
            # 行号 + 格子内容
            row_str = f'{i+1}|' + '|'.join(f' {cell} ' for cell in row) + '|\n'
            rows.append(row_str)
            rows.append(top_border)
        
        return header + top_border + ''.join(rows)
    
    def parse_coordinate(self, coord: str) -> Optional[Tuple[int, int]]:
        """
        解析坐标字符串为数组索引
        
        Args:
            coord: 坐标字符串，如 "A1", "C3", "F6"
            
        Returns:
            (row, col) 元组，或 None 如果坐标无效
        """
        coord = coord.strip().upper()
        
        if len(coord) < 2:
            return None
        
        # 分离字母和数字部分
        col_char = coord[0]
        row_str = coord[1:]
        
        # 验证列
        if col_char not in self.COLS:
            return None
        
        # 验证行
        try:
            row = int(row_str) - 1  # 转换为 0 索引
            if row < 0 or row > 5:
                return None
        except ValueError:
            return None
        
        col = self.COLS.index(col_char)
        return (row, col)
    
    def format_coordinate(self, row: int, col: int) -> str:
        """
        将数组索引格式化为坐标字符串
        
        Args:
            row: 行索引 (0-5)
            col: 列索引 (0-5)
            
        Returns:
            坐标字符串，如 "A1", "C3"
        """
        return f'{self.COLS[col]}{row + 1}'
    
    def is_valid_move(self, row: int, col: int) -> bool:
        """
        检查落子是否有效
        
        Args:
            row: 行索引
            col: 列索引
            
        Returns:
            True 如果落子有效
        """
        if not (0 <= row < 6 and 0 <= col < 6):
            return False
        return self.board[row][col] == ' '
    
    def make_move(self, row: int, col: int) -> bool:
        """
        执行落子
        
        Args:
            row: 行索引
            col: 列索引
            
        Returns:
            True 如果落子成功
        """
        if not self.is_valid_move(row, col):
            return False
        
        # 落子
        self.board[row][col] = self.current_player
        self.move_history.append((row, col, self.current_player))
        
        # 检查胜负
        if self.check_win(row, col):
            self.game_over = True
            self.winner = self.current_player
            return True
        
        # 检查平局
        if self.is_board_full():
            self.game_over = True
            self.winner = 'Draw'
            return True
        
        # 切换玩家
        self.current_player = 'O' if self.current_player == 'X' else 'X'
        return True
    
    def check_win(self, row: int, col: int) -> bool:
        """
        检查指定位置是否形成五子连珠
        
        Args:
            row: 最后落子的行
            col: 最后落子的列
            
        Returns:
            True 如果形成五子连珠
        """
        player = self.board[row][col]
        
        # 四个方向：横、竖、左上 - 右下斜、右上 - 左下斜
        directions = [
            (0, 1),   # 横向
            (1, 0),   # 纵向
            (1, 1),   # 斜向（左上到右下）
            (1, -1)   # 斜向（右上到左下）
        ]
        
        for dr, dc in directions:
            count = 1  # 当前落子
            
            # 正方向计数
            r, c = row + dr, col + dc
            while 0 <= r < 6 and 0 <= c < 6 and self.board[r][c] == player:
                count += 1
                r += dr
                c += dc
            
            # 反方向计数
            r, c = row - dr, col - dc
            while 0 <= r < 6 and 0 <= c < 6 and self.board[r][c] == player:
                count += 1
                r -= dr
                c -= dc
            
            if count >= 5:
                return True
        
        return False
    
    def is_board_full(self) -> bool:
        """检查棋盘是否已满"""
        for row in self.board:
            if ' ' in row:
                return False
        return True
    
    def get_available_moves(self) -> List[Tuple[int, int]]:
        """获取所有可落子位置"""
        moves = []
        for i in range(6):
            for j in range(6):
                if self.board[i][j] == ' ':
                    moves.append((i, j))
        return moves
    
    def ai_move(self) -> Optional[Tuple[int, int]]:
        """
        AI 落子（随机选择空位）
        
        Returns:
            (row, col) 元组，或 None 如果没有可落子位置
        """
        available = self.get_available_moves()
        if not available:
            return None
        
        return random.choice(available)
    
    def get_status(self) -> str:
        """
        获取游戏状态文本
        
        Returns:
            状态描述字符串
        """
        if self.game_over:
            if self.winner == 'Draw':
                return '游戏结束 - 平局！'
            else:
                return f'游戏结束 - {"玩家" if self.winner == "X" else "AI"}获胜！'
        
        if self.current_player == 'X':
            return '轮到玩家落子 (X)'
        else:
            return '轮到 AI 落子 (O)'
    
    def reset_game(self):
        """重置游戏"""
        self.__init__()
    
    def get_last_move(self) -> Optional[Tuple[int, int, str]]:
        """获取最后一步落子信息"""
        return self.move_history[-1] if self.move_history else None


# ============ 飞书机器人集成示例 ============

def handle_feishu_message(message: str, game: Gomoku6x6) -> str:
    """
    处理飞书消息
    
    Args:
        message: 用户消息
        game: 游戏实例
        
    Returns:
        回复消息
    """
    message = message.strip().upper()
    
    # 游戏结束检查
    if game.game_over:
        return f'{game.draw_board()}\n{game.get_status()}\n\n输入"新游戏"重新开始'
    
    # 特殊命令
    if message in ['新游戏', 'START', 'BEGIN', 'PLAY GOMOKU', '开始五子棋']:
        game.reset_game()
        return f'新游戏开始！\n\n{game.draw_board()}\n{game.get_status()}\n\n请输入坐标落子（如 A1, C3）'
    
    if message in ['结束游戏', 'QUIT', 'EXIT', '认输']:
        return '游戏已结束。输入"新游戏"重新开始。'
    
    if message in ['当前局面', '游戏状态', 'STATUS']:
        return f'{game.draw_board()}\n{game.get_status()}'
    
    # 尝试解析为坐标
    coord = game.parse_coordinate(message)
    if coord is None:
        return '无效坐标！请使用 A1-F6 格式（如 A1, C3, F6）'
    
    row, col = coord
    
    # 检查是否是玩家的回合
    if game.current_player != 'X':
        return '请等待 AI 落子...'
    
    # 玩家落子
    if not game.make_move(row, col):
        return f'{game.draw_board()}\n该位置已有棋子，请选择其他位置。'
    
    # 检查游戏是否结束
    if game.game_over:
        return f'{game.draw_board()}\n{game.get_status()}\n\n输入"新游戏"重新开始'
    
    # AI 落子
    ai_row, ai_col = game.ai_move()
    game.make_move(ai_row, ai_col)
    
    # 返回结果
    response = f'玩家落子：{game.format_coordinate(row, col)}\n'
    response += f'AI 落子：{game.format_coordinate(ai_row, ai_col)}\n\n'
    response += game.draw_board()
    response += f'\n{game.get_status()}'
    
    if game.game_over:
        response += '\n\n输入"新游戏"重新开始'
    
    return response


# ============ 命令行测试 ============

def play_cli():
    """命令行模式测试"""
    game = Gomoku6x6()
    
    print('=' * 40)
    print('欢迎游玩 6x6 五子棋！')
    print('坐标格式：A1-F6（如 A1, C3, F6）')
    print('输入"quit"退出游戏')
    print('=' * 40)
    print()
    
    while True:
        print(game.draw_board())
        print(game.get_status())
        
        if game.game_over:
            print('\n输入"new"开始新游戏，"quit"退出')
            cmd = input('> ').strip().lower()
            if cmd == 'new':
                game.reset_game()
                continue
            elif cmd == 'quit':
                print('再见！')
                break
            continue
        
        # 玩家输入
        user_input = input('请输入坐标 (A1-F6): ').strip()
        
        if user_input.lower() == 'quit':
            print('再见！')
            break
        
        if user_input.lower() == 'new':
            game.reset_game()
            continue
        
        # 处理落子
        response = handle_feishu_message(user_input, game)
        print()
        print(response)
        print()


if __name__ == '__main__':
    play_cli()
