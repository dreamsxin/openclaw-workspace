"""Tests for indexer module — manifest and incremental diff."""

import time
from pathlib import Path

from rag_builder.indexer import (
    FileRecord,
    IndexDiff,
    IndexManifest,
    compute_diff,
    file_content_hash,
)


class TestFileContentHash:
    def test_same_content_same_hash(self, tmp_dir):
        f = tmp_dir / "test.txt"
        f.write_text("hello world")
        h1 = file_content_hash(f)
        h2 = file_content_hash(f)
        assert h1 == h2

    def test_different_content_different_hash(self, tmp_dir):
        f1 = tmp_dir / "a.txt"
        f2 = tmp_dir / "b.txt"
        f1.write_text("hello")
        f2.write_text("world")
        assert file_content_hash(f1) != file_content_hash(f2)

    def test_hash_is_sha256(self, tmp_dir):
        import hashlib
        f = tmp_dir / "test.txt"
        content = b"test content"
        f.write_bytes(content)
        expected = hashlib.sha256(content).hexdigest()
        assert file_content_hash(f) == expected


class TestFileRecord:
    def test_creation(self):
        rec = FileRecord(
            path="/tmp/test.txt",
            content_hash="abc123",
            mtime=1000.0,
            chunk_count=5,
            indexed_at=2000.0,
            file_size=1024,
        )
        assert rec.path == "/tmp/test.txt"
        assert rec.chunk_count == 5

    def test_defaults(self):
        rec = FileRecord(
            path="/tmp/test.txt",
            content_hash="abc",
            mtime=1000.0,
            chunk_count=1,
            indexed_at=2000.0,
        )
        assert rec.file_size == 0


class TestIndexManifest:
    def test_empty_manifest(self):
        m = IndexManifest()
        assert m.files == {}
        assert m.total_chunks == 0
        assert m.version == 1

    def test_add_file(self):
        m = IndexManifest()
        rec = FileRecord(
            path="/tmp/a.txt",
            content_hash="hash1",
            mtime=1000.0,
            chunk_count=10,
            indexed_at=2000.0,
        )
        m.add_file(rec)
        assert len(m.files) == 1
        assert m.total_chunks == 10

    def test_update_file(self):
        m = IndexManifest()
        rec1 = FileRecord(
            path="/tmp/a.txt", content_hash="old", mtime=1000.0,
            chunk_count=5, indexed_at=2000.0,
        )
        rec2 = FileRecord(
            path="/tmp/a.txt", content_hash="new", mtime=2000.0,
            chunk_count=8, indexed_at=3000.0,
        )
        m.add_file(rec1)
        m.add_file(rec2)

        assert len(m.files) == 1
        assert m.total_chunks == 8  # Updated count
        assert m.files["/tmp/a.txt"].content_hash == "new"

    def test_remove_file(self):
        m = IndexManifest()
        rec = FileRecord(
            path="/tmp/a.txt", content_hash="h", mtime=1000.0,
            chunk_count=10, indexed_at=2000.0,
        )
        m.add_file(rec)
        removed = m.remove_file("/tmp/a.txt")

        assert removed == 10
        assert len(m.files) == 0
        assert m.total_chunks == 0

    def test_remove_nonexistent(self):
        m = IndexManifest()
        assert m.remove_file("/tmp/nope.txt") == 0

    def test_save_and_load(self, tmp_dir):
        m = IndexManifest()
        m.add_file(FileRecord(
            path="/tmp/a.txt", content_hash="abc", mtime=1000.0,
            chunk_count=5, indexed_at=2000.0, file_size=512,
        ))

        path = tmp_dir / "manifest.json"
        m.save(path)

        loaded = IndexManifest.load(path)
        assert len(loaded.files) == 1
        assert loaded.total_chunks == 5
        assert loaded.files["/tmp/a.txt"].content_hash == "abc"
        assert loaded.files["/tmp/a.txt"].file_size == 512

    def test_load_nonexistent(self, tmp_dir):
        path = tmp_dir / "nonexistent.json"
        m = IndexManifest.load(path)
        assert m.files == {}
        assert m.total_chunks == 0

    def test_load_corrupted(self, tmp_dir):
        path = tmp_dir / "bad.json"
        path.write_text("not valid json{{{")
        m = IndexManifest.load(path)
        assert m.files == {}  # Should return empty, not crash


class TestComputeDiff:
    def test_all_new(self, tmp_dir):
        f1 = tmp_dir / "a.txt"
        f2 = tmp_dir / "b.txt"
        f1.write_text("content a")
        f2.write_text("content b")

        manifest = IndexManifest()
        diff = compute_diff([f1, f2], manifest)

        assert len(diff.new) == 2
        assert len(diff.modified) == 0
        assert len(diff.deleted) == 0
        assert diff.needs_update is True

    def test_no_changes(self, tmp_dir):
        f = tmp_dir / "a.txt"
        f.write_text("content")

        manifest = IndexManifest()
        manifest.add_file(FileRecord(
            path=str(f.resolve()),
            content_hash=file_content_hash(f),
            mtime=f.stat().st_mtime,
            chunk_count=1,
            indexed_at=time.time(),
        ))

        diff = compute_diff([f], manifest)
        assert len(diff.new) == 0
        assert len(diff.modified) == 0
        assert len(diff.deleted) == 0
        assert len(diff.unchanged) == 1
        assert diff.needs_update is False

    def test_modified_file(self, tmp_dir):
        f = tmp_dir / "a.txt"
        f.write_text("original")

        manifest = IndexManifest()
        manifest.add_file(FileRecord(
            path=str(f.resolve()),
            content_hash=file_content_hash(f),
            mtime=f.stat().st_mtime,
            chunk_count=1,
            indexed_at=time.time(),
        ))

        # Modify the file
        f.write_text("modified content")
        # Update mtime to trigger check
        import os
        os.utime(f, (f.stat().st_atime, f.stat().st_mtime + 10))

        diff = compute_diff([f], manifest)
        assert len(diff.modified) == 1
        assert len(diff.unchanged) == 0

    def test_deleted_file(self, tmp_dir):
        f = tmp_dir / "a.txt"
        f.write_text("content")
        abs_path = str(f.resolve())

        manifest = IndexManifest()
        manifest.add_file(FileRecord(
            path=abs_path,
            content_hash="abc",
            mtime=f.stat().st_mtime,
            chunk_count=1,
            indexed_at=time.time(),
        ))

        # Delete the file
        f.unlink()

        diff = compute_diff([], manifest)
        assert len(diff.deleted) == 1
        assert diff.deleted[0] == abs_path

    def test_mixed_changes(self, tmp_dir):
        # New file
        new_f = tmp_dir / "new.txt"
        new_f.write_text("new content")

        # Unchanged file
        old_f = tmp_dir / "old.txt"
        old_f.write_text("old content")

        # Deleted file (in manifest but not on disk)
        manifest = IndexManifest()
        manifest.add_file(FileRecord(
            path=str(old_f.resolve()),
            content_hash=file_content_hash(old_f),
            mtime=old_f.stat().st_mtime,
            chunk_count=1,
            indexed_at=time.time(),
        ))
        manifest.add_file(FileRecord(
            path=str(tmp_dir / "deleted.txt"),
            content_hash="xxx",
            mtime=1000.0,
            chunk_count=1,
            indexed_at=1000.0,
        ))

        diff = compute_diff([new_f, old_f], manifest)
        assert len(diff.new) == 1
        assert len(diff.deleted) == 1
        assert len(diff.unchanged) == 1

    def test_summary(self):
        diff = IndexDiff()
        diff.new = [Path("a"), Path("b")]
        diff.modified = [Path("c")]
        diff.deleted = ["/tmp/d"]
        diff.unchanged = ["/tmp/e", "/tmp/f"]

        s = diff.summary()
        assert "新增 2" in s
        assert "修改 1" in s
        assert "删除 1" in s
        assert "未变 2" in s

    def test_empty_diff_summary(self):
        diff = IndexDiff()
        assert diff.summary() == "无变化"
