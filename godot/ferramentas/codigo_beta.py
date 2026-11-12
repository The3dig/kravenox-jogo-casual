"""Gera um código de beta tester para uma pessoa.

Uso: python3 ferramentas/codigo_beta.py Nome
Mostra o código (mande só para a pessoa) e a linha para colar em
CODIGOS_BETA no jogo.gd. O código em si não fica guardado no repositório.
"""
import hashlib, secrets, sys, unicodedata

nome = " ".join(sys.argv[1:]).strip() or "Amigo"
base = unicodedata.normalize("NFKD", nome).encode("ascii", "ignore").decode().upper()
prefixo = "".join(c for c in base if c.isalpha())[:4] or "BETA"
alf = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"
codigo = prefixo + "-" + "".join(secrets.choice(alf) for _ in range(4))
h = hashlib.sha256(codigo.replace("-", "").encode()).hexdigest()
print("Código para %s: %s" % (nome, codigo))
print('Linha para CODIGOS_BETA:\n\t"%s": "%s",' % (h, nome))
