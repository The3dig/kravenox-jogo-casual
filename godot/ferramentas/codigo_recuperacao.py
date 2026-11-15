"""Gera um código CURTO de recuperação de progresso para quem perdeu o save.

Uso: python3 ferramentas/codigo_recuperacao.py Nome
Mostra o código (mande só para a pessoa) e o hash. No jogo.gd, crie uma
entrada em RECUPERACOES com esse hash e o progresso a devolver (capítulo,
melhorias, skins, fragmentos). A pessoa digita o código em Ajustes → Código
de presente; o progresso é SOMADO ao do aparelho, nunca trocado.
O código em si não fica guardado no repositório.
"""
import hashlib, secrets, sys, unicodedata

nome = " ".join(sys.argv[1:]).strip() or "Amigo"
base = unicodedata.normalize("NFKD", nome).encode("ascii", "ignore").decode().upper()
prefixo = "".join(c for c in base if c.isalpha())[:4] or "VOLTA"
alf = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"
codigo = prefixo + "-" + "".join(secrets.choice(alf) for _ in range(5))
print("Código para %s: %s" % (nome, codigo))
print("Hash para RECUPERACOES:", hashlib.sha256(codigo.replace("-", "").encode()).hexdigest())
