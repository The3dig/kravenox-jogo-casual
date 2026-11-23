# Como gerar o app de Android (APK) para testar

Gerado pela primeira vez em 23/11/2026, numa sessão na nuvem, sem o Android
Studio. O que precisa:

1. **Godot 4.5** e as **export templates** de Android (do arquivo
   `Godot_v4.5-stable_export_templates.tpz` do GitHub do Godot, só
   `android_debug.apk`, `android_release.apk` e `version.txt`, em
   `~/.local/share/godot/export_templates/4.5.stable/`).
2. **Java** (JDK 17 ou 21) e o **apksigner** (`apt-get install apksigner zipalign`).
   O site do Google com o kit Android estava bloqueado na nuvem; o Godot só
   precisa de uma pasta de "SDK" com `build-tools/<versão>/apksigner` e
   `platform-tools/adb` (pode ser um script vazio).
3. Nas configurações do editor (`~/.config/godot/editor_settings-4.5.tres`):
   `export/android/android_sdk_path`, `java_sdk_path` e a chave de teste
   (`debug_keystore`, usuário `androiddebugkey`, senha `android`).
4. Exportar: `godot --headless --path godot --export-debug "Android" build/android/Kravenox-teste.apk`

A configuração "Android" está em `export_presets.cfg` (pacote
`io.github.the3dig.kravenox.quadros`, em pé, internet e vibração).

**Para a loja (Google Play)** é preciso um arquivo AAB assinado com a chave de
envio da conta do Rone (uma chave própria, guardada fora do repositório; NUNCA
publicar a chave nem a senha). A chave de teste serve só para instalar no
celular e testar.
