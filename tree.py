#!/usr/bin/env python3
# ruff: noqa: RUF001, RUF002, RUF003
"""
tree.py - выводит дерево проекта, исключая мусорные директории и файлы
python tree.py .
python tree.py . --show-content     # + содержимое файлов
python backend/app/utils/tree.py . --show-content -o structure.txt   # сохранить в файл
"""

import argparse
import fnmatch
import sys
from contextlib import contextmanager
from pathlib import Path

# Список игнорируемых элементов
IGNORE_LIST = {
    "__pycache__",
    ".git",
    ".venv",
    "venv",
    ".env",
    ".env.local",
    ".env.prod",
    ".DS_Store",
    ".pytest_cache",
    ".mypy_cache",
    ".ruff_cache",
    ".terraform"
    ".vscode",
    ".idea",
    "*.pyc",
    "*.log",
    "*.tmp",
    "Thumbs.db",
    # "__init__.py",
    "alembic/versions",
    "ansible",
    "redis/data",
    "script.py.mako",
    "tree.py",
    "uv.lock",
}

# Максимальный размер файла для вывода содержимого (в байтах)
MAX_FILE_SIZE = 10 * 1024  # 10 КБ


@contextmanager
def output_redirector(filepath: Path | None):
    """
    Контекстный менеджер для перенаправления stdout в файл или консоль.
    """
    if filepath is None:
        yield sys.stdout
    else:
        with filepath.open("w", encoding="utf-8") as f:
            yield f


def should_ignore(relative_path: Path) -> bool:
    """
    Проверяет, нужно ли игнорировать файл/папку по относительному пути.
    """
    rel_str = str(relative_path).replace("\\", "/")  # унифицируем разделители

    for pattern in IGNORE_LIST:
        if pattern.startswith("*."):
            # Паттерн для имён (без пути)
            if relative_path.name.endswith(pattern[1:]):
                return True
        elif pattern.endswith("/"):
            # Явное указание директории
            if fnmatch.fnmatch(rel_str + "/", pattern):
                return True
        else:
            # Точное совпадение пути ИЛИ совпадение имени (для обратной совместимости)
            if pattern in (rel_str, relative_path.name):
                return True
    return False


def read_file_content(file_path: Path) -> str:
    """
    Читает содержимое файла с обработкой ошибок и ограничением размера.
    """
    try:
        # Не читаем бинарные файлы по расширению
        binary_exts = {
            ".png",
            ".jpg",
            ".jpeg",
            ".gif",
            ".pdf",
            ".zip",
            ".tar",
            ".gz",
            ".sqlite",
            ".db",
        }
        if file_path.suffix.lower() in binary_exts:
            return "  [бинарный файл]"

        if file_path.stat().st_size > MAX_FILE_SIZE:
            return f"  [Файл слишком большой (> {MAX_FILE_SIZE // 1024} КБ)]"

        with file_path.open(encoding="utf-8", errors="replace") as f:
            lines = f.read().splitlines()
            if not lines:
                return "  (пустой файл)"
            # Добавляем отступ ко всем строкам
            return "\n".join(f"  {line}" for line in lines)
    except OSError as e:  # FileNotFoundError, PermissionError и т.д.
        return f"  [Ошибка ввода/вывода: {e}]"
    except UnicodeDecodeError as e:
        return f"  [Ошибка кодировки: {e}]"


def tree(
    dir_path: Path,
    prefix: str = "",
    show_content: bool = False,
    root: Path | None = None,
    output=None,
):
    """
    Рекурсивно выводит структуру директории.
    Получаем содержимое, фильтруем игнорируемые элементы
    """
    if root is None:
        root = dir_path.resolve()

    try:
        filtered_entries = []
        for p in dir_path.iterdir():
            try:
                # Получаем относительный путь от корня проекта
                rel_path = p.relative_to(root)
            except ValueError:
                # Если путь не внутри root (маловероятно, но на всякий случай)
                rel_path = p.name
            if not should_ignore(rel_path):
                filtered_entries.append(p)

        contents = sorted(filtered_entries, key=lambda p: (p.is_file(), p.name.lower()))
    except PermissionError:
        print(prefix + "└── [не доступно]", file=output)
        return

    if not contents:
        return

    pointers = ["├── "] * (len(contents) - 1) + ["└── "]

    for pointer, path in zip(pointers, contents, strict=True):
        print(prefix + pointer + path.name, file=output)
        if path.is_dir():
            extension = "│   " if pointer == "├── " else "    "
            tree(
                path,
                prefix + extension,
                show_content=show_content,
                root=root,
                output=output,
            )
        elif show_content and path.is_file():
            # Выводим содержимое файла
            content = read_file_content(path)
            if content:
                # Добавляем отступ под файлом
                indent = prefix + ("│   " if pointer == "├── " else "    ")
                for line in content.splitlines():
                    print(indent + line, file=output)


def main():
    parser = argparse.ArgumentParser(
        description="Выводит дерево проекта с опциональным показом содержимого файлов"
    )
    parser.add_argument(
        "path",
        nargs="?",
        default=".",
        help="Корневая директория (по умолчанию: текущая)",
    )
    parser.add_argument(
        "-c",
        "--show-content",
        action="store_true",
        help="Показывать содержимое файлов (ограничено 10 КБ на файл)",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        metavar="FILE",
        help="Сохранить результат в файл вместо вывода в терминал",
    )

    args = parser.parse_args()
    root_path = Path(args.path).resolve()

    if not root_path.exists():
        print(f"Ошибка: путь '{root_path}' не существует.", file=sys.stderr)
        sys.exit(1)

    try:
        with output_redirector(args.output) as out:
            print("СТРУКТУРА ПРОЕКТА:", file=out)
            print(root_path.name + "/", file=out)
            tree(root_path, show_content=args.show_content, root=root_path, output=out)

        if args.output:
            print(f"✓ Результат сохранён в {args.output}", file=sys.stderr)
    except OSError as e:
        print(f"Ошибка записи в файл '{args.output}': {e}", file=sys.stderr)
        sys.exit(1)

    # print("СТРУКТУРА ПРОЕКТА:")
    # print(root_path.name + "/")
    # tree(root_path, show_content=args.show_content, root=root_path)


if __name__ == "__main__":
    main()
