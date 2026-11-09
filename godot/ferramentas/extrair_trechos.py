"""Tira trechos curtos de narração de cada capítulo do RPG (kravenox-jogar/rpg/js)
e grava godot/dados/trechos.json. O RPG adapta o livro; os trechos aparecem
nos Eventos do Livro e nas Crônicas do Quadros do Cisma.

Uso: python3 extrair_trechos.py <pasta rpg/js> <saida.json>
"""
import json, re, sys, pathlib

pasta = pathlib.Path(sys.argv[1])
arquivos = [("story.js", 0), ("story2.js", 0), ("story3.js", 0), ("l2story1.js", 35), ("l2story2.js", 35), ("l2story3.js", 35)]
re_cap = re.compile(r"(?:Capítulo (\d+)\\n|\bchapter\((\d+),)")
re_nar = re.compile(r"\bnar\((['\"])((?:\\.|(?!\1).)*)\1")
trechos = {}
for nome, soma in arquivos:
    atual = None
    for linha in (pasta / nome).read_text(encoding="utf-8").splitlines():
        m = re_cap.search(linha)
        if m:
            atual = int(m.group(1) or m.group(2)) + soma
            trechos.setdefault(atual, [])
            continue
        if atual is None:
            continue
        for n in re_nar.finditer(linha):
            t = n.group(2).replace("\\'", "'").replace('\\"', '"').replace("\\n", " ").strip()
            if 40 <= len(t) <= 200 and "aprendeu" not in t and "+" not in t:
                trechos[atual].append(t)
saida = {}
for c, ls in sorted(trechos.items()):
    if not ls or c > 76:
        continue
    escolha = []
    for t in ls:
        if sum(len(x) for x in escolha) + len(t) > 240:
            break
        escolha.append(t)
    if not escolha:
        escolha = [ls[0]]
    saida[str(c)] = " ".join(escolha)
pathlib.Path(sys.argv[2]).write_text(json.dumps(saida, ensure_ascii=False, indent=1), encoding="utf-8")
print(len(saida), "capítulos com trecho")
