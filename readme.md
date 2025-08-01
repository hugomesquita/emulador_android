# README - Android Emulator (AVD) no Fedora (Sem Android Studio)

Este guia explica como instalar e desinstalar o Android Emulator (AVD) no Fedora sem precisar instalar o Android Studio completo, usando um script automatizado com aceleração via KVM quando disponível.

---

## Requisitos

- Sistema Fedora atualizado
- Processador com suporte a virtualização (VT-x/AMD-V) — recomendado para melhor desempenho
- Usuário com permissões sudo
- Conexão com internet

---

## Funcionalidades do script

- Instala dependências necessárias (Java JDK, QEMU, libvirt, etc)
- Baixa e configura Android SDK Command Line Tools (somente linha de comando)
- Instala o Android Emulator, platform tools, sistema de imagens e plataformas
- Cria um AVD com nome escolhido pelo usuário
- Ativa aceleração via KVM se disponível
- Adiciona o usuário ao grupo `libvirt` para usar virtualização sem sudo (precisa logout/login)
- Desinstala completamente o SDK e remove pacotes instalados
- Menu interativo para facilitar uso

---

## Como usar o script

### 1. Baixe o script

Salve o script `android_emulator.sh` em seu diretório preferido.

### 2. Dê permissão para executar

```bash
chmod +x android_emulator.sh
```

### 3. Execute o script
```bash
./android_emulator.sh
```


### 4. Menu Interativo
Você verá as opções:

1) Instalar Android Emulator (AVD)
2) Desinstalar completamente
3) Sair

Escolha a opção desejada digitando o número correspondente.


## Instalação e Inicialização do Android Emulator (Opção 1)
- Informe o nome que deseja dar para seu AVD (exemplo: pixel_7).
- O script irá instalar dependências, baixar ferramentas, aceitar licenças e criar o AVD.
- Se seu processador suporta virtualização, o script ativa o KVM e adiciona você ao grupo libvirt.
- Importante: após adicionar ao grupo libvirt, faça logout e login para que as permissões tenham efeito.
- Ao final, o script mostrará o comando para iniciar o emulador:

```bash
emulator -avd nome_do_seu_emulador -accel on
```
Substitua nome_do_seu_emulador pelo nome escolhido durante a instalação.

## Desinstalação Completa (Opção 2)
- Remove a pasta do Android SDK ($HOME/Android) criada pelo script
- Para o serviço libvirtd
- Remove os pacotes do sistema instalados pelo script
- Confirmação antes de executar



## Pontos de ATENÇÃO
### Verificação de Virtualização
Você pode verificar se seu processador suporta virtualização com:
```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```
Se retornar 0, seu processador não suporta virtualização e o emulador rodará sem aceleração, podendo ficar lento.

### Configurando as variáveis de ambiente
Para executar o comando emulator é necessário configurar as variáveis de ambiente, você pode adicionar essas linhas ao seu arquivo ~/.bashrc ou ~/.zshrc para carregar automaticamente o SDK no PATH toda vez que abrir o terminal:


### Problemas comuns
- Se o emulador não iniciar por falta de permissões, faça logout e login para aplicar grupos.
- Certifique-se que o KVM está habilitado no BIOS/UEFI do seu notebook.
- Se a máquina virtual não iniciar, verifique se o serviço libvirtd está ativo:


```bash
sudo systemctl status libvirtd
```

E inicie com:
```bash
sudo systemctl start libvirtd
```



```bash 
export ANDROID_HOME=$HOME/Android
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH
```




### Personalizações
- O script instala a API Android 33 por padrão (android-33). Para usar outra, edite a variável ANDROID_API no script.
- Pode criar mais de um AVD rodando versões diferentes do Android usando o script várias vezes com nomes diferentes.


### Exemplo Rápido de Execução

```bash
chmod +x android_emulator_menu.sh
./android_emulator_menu.sh
# Escolha opção 1
# Digite o nome do AVD: pixel_7
# Aguarde instalação e criação
# Quando terminar, inicie:
emulator -avd pixel_7 -accel on
```




### Contribuições e Feedback

Este script e este guia foram criados para facilitar a instalação do Android Emulator no Fedora de forma simples e eficiente, sem a necessidade de instalar o Android Studio completo.

Se você encontrou algum problema, tem sugestões de melhorias, ou deseja adicionar funcionalidades, sua contribuição será muito bem-vinda!  

Por favor, sinta-se à vontade para:

- **Abrir uma issue** relatando bugs, dificuldades ou sugestões;
- **Enviar pull requests** com correções e melhorias;
- Compartilhar este projeto com outros usuários que possam se beneficiar.

Seu feedback ajuda a tornar essa ferramenta cada vez melhor para toda a comunidade. Obrigado por colaborar! 🚀
