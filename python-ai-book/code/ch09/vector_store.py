"""第9章 向量存储 — 基于嵌入的长期记忆"""

import chromadb
from openai import OpenAI
import numpy as np


class VectorMemory:
    """基于向量的长期记忆"""

    def __init__(self, collection_name: str = "memory"):
        self.client = chromadb.Client()
        self.collection = self.client.get_or_create_collection(
            name=collection_name,
            metadata={"hnsw:space": "cosine"},
        )
        self.openai = OpenAI()

    def remember(self, text: str, metadata: dict = None):
        """存储一条记忆"""
        embedding = self._embed(text)
        doc_id = f"doc_{self.collection.count() + 1}"
        self.collection.add(
            ids=[doc_id],
            embeddings=[embedding],
            documents=[text],
            metadatas=[metadata or {}],
        )

    def recall(self, query: str, n_results: int = 3) -> list[str]:
        """回忆与查询相关的记忆"""
        embedding = self._embed(query)
        results = self.collection.query(
            query_embeddings=[embedding],
            n_results=n_results,
        )
        return results["documents"][0] if results["documents"] else []

    def forget(self, doc_id: str):
        """删除一条记忆"""
        self.collection.delete(ids=[doc_id])

    def _embed(self, text: str) -> list[float]:
        response = self.openai.embeddings.create(
            model="text-embedding-3-small", input=text
        )
        return response.data[0].embedding


def cosine_similarity(a: list[float], b: list[float]) -> float:
    """计算余弦相似度"""
    a_arr, b_arr = np.array(a), np.array(b)
    return float(np.dot(a_arr, b_arr) / (np.linalg.norm(a_arr) * np.linalg.norm(b_arr)))


if __name__ == "__main__":
    memory = VectorMemory()

    # 存储记忆
    memory.remember("用户喜欢用Python", {"category": "preference"})
    memory.remember("用户在北京工作", {"category": "location"})
    memory.remember("用户正在学习机器学习", {"category": "interest"})

    # 回忆
    results = memory.recall("用户喜欢什么编程语言？")
    print("回忆结果:", results)
