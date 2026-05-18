"""第6章 文件级记忆管理 — 持久化重要信息"""

import json
from pathlib import Path
from datetime import datetime


class FileMemory:
    """文件级记忆管理"""

    def __init__(self, memory_dir: str = ".memory"):
        self.dir = Path(memory_dir)
        self.dir.mkdir(exist_ok=True)

    def save(self, key: str, value: str, category: str = "general"):
        """保存一条记忆"""
        path = self.dir / f"{category}.json"
        data = self._load(path)
        data[key] = {
            "value": value,
            "updated": datetime.now().isoformat(),
        }
        path.write_text(json.dumps(data, ensure_ascii=False, indent=2))

    def recall(self, key: str, category: str = "general") -> str | None:
        """回忆一条记忆"""
        data = self._load(self.dir / f"{category}.json")
        entry = data.get(key)
        return entry["value"] if entry else None

    def recall_all(self, category: str = "general") -> dict:
        """回忆某个类别的所有记忆"""
        return {
            k: v["value"]
            for k, v in self._load(self.dir / f"{category}.json").items()
        }

    def forget(self, key: str, category: str = "general"):
        """删除一条记忆"""
        path = self.dir / f"{category}.json"
        data = self._load(path)
        if key in data:
            del data[key]
            path.write_text(json.dumps(data, ensure_ascii=False, indent=2))

    def _load(self, path: Path) -> dict:
        if path.exists():
            return json.loads(path.read_text())
        return {}


if __name__ == "__main__":
    memory = FileMemory()

    # 保存
    memory.save("user_name", "Dreamszhu", "user")
    memory.save("preferred_lang", "Python", "user")
    memory.save("theme", "dark", "settings")

    # 读取
    print("用户名:", memory.recall("user_name", "user"))
    print("所有用户偏好:", memory.recall_all("user"))

    # 删除
    memory.forget("theme", "settings")
    print("主题设置:", memory.recall("theme", "settings"))
