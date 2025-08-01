#!/bin/bash

set -e

ANDROID_HOME="$HOME/Android"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"
CMDLINE_ZIP="commandlinetools.zip"
ANDROID_API="android-33"

function instalar() {
  echo "Iniciando instalação do Android Emulator (AVD)..."

  echo "Qual nome deseja dar para seu AVD? (exemplo: pixel_7)"
  read -r AVD_NAME

  if [ -z "$AVD_NAME" ]; then
    echo "Nome do AVD não pode ser vazio. Abortando instalação."
    return
  fi

  echo "Instalando dependências do sistema necessárias..."
  sudo dnf install -y zip unzip qemu-kvm libvirt virt-manager

  # Verificar suporte a virtualização KVM
  KVM_AVAILABLE=$(egrep -c '(vmx|svm)' /proc/cpuinfo || true)
  if [ "$KVM_AVAILABLE" -eq 0 ]; then
    echo "Atenção: Seu processador não parece suportar virtualização KVM."
    echo "O emulador pode funcionar sem aceleração, mas será mais lento."
  else
    echo "Virtualização KVM detectada. Ativando serviço libvirtd..."
    sudo systemctl enable --now libvirtd

    # Verificar se usuário está no grupo libvirt
    if ! groups "$USER" | grep -qw libvirt; then
      echo "Adicionando usuário '$USER' ao grupo 'libvirt' para permitir uso do KVM sem sudo."
      sudo usermod -aG libvirt "$USER"
      echo "Por favor, faça logout e login novamente para aplicar as permissões de grupo."
    fi
  fi

  mkdir -p "$ANDROID_HOME/cmdline-tools"
  cd "$ANDROID_HOME" || exit

  if [ ! -f "$CMDLINE_ZIP" ]; then
    echo "Baixando Command Line Tools..."
    curl -o "$CMDLINE_ZIP" "$CMDLINE_TOOLS_URL"
  fi

  echo "Extraindo Command Line Tools..."
  unzip -oq "$CMDLINE_ZIP" -d cmdline-tools
  mv -n cmdline-tools/cmdline-tools cmdline-tools/latest 2>/dev/null || true

  export ANDROID_HOME
  export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

  echo "Aceitando licenças do SDK..."
  yes | sdkmanager --sdk_root="$ANDROID_HOME" --licenses

  echo "Instalando componentes do SDK..."
  sdkmanager --sdk_root="$ANDROID_HOME" \
    "emulator" \
    "platform-tools" \
    "platforms;$ANDROID_API" \
    "system-images;$ANDROID_API;google_apis;x86_64" \
    "cmdline-tools;latest"

  echo "Criando AVD chamado $AVD_NAME..."
  echo no | avdmanager create avd -n "$AVD_NAME" -k "system-images;$ANDROID_API;google_apis;x86_64" --force

  echo "AVD criado com sucesso!"

  echo -e "\nPara iniciar o emulador com aceleração KVM, use o comando:\n"
  echo "emulator -avd $AVD_NAME -accel on"

  echo -e "\nSe receber erros relacionados a permissões, faça logout/login ou reinicie seu computador para aplicar as mudanças de grupo."
}

function desinstalar() {
  echo "Iniciando desinstalação completa do Android Emulator e SDK instalados por este script."

  read -p "Tem certeza que deseja remover a pasta $ANDROID_HOME e os componentes do SDK? (s/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Desinstalação cancelada."
    return
  fi

  # Parar o serviço libvirtd
  echo "Parando serviço libvirtd..."
  sudo systemctl stop libvirtd

  # Remover Android SDK instalado
  echo "Removendo $ANDROID_HOME..."
  rm -rf "$ANDROID_HOME"

  # Remover pacotes do sistema (opcional)
  echo "Removendo pacotes do sistema instalados (java, qemu, libvirt, virt-manager)..."
  sudo dnf remove -y java-17-openjdk zip unzip qemu-kvm libvirt virt-manager

  echo "Remoção concluída."
}

while true; do
  echo "---------------------------------------"
  echo "   Android Emulator AVD - Fedora Setup  "
  echo "---------------------------------------"
  echo "1) Instalar Android Emulator (AVD)"
  echo "2) Desinstalar completamente"
  echo "3) Sair"
  echo -n "Escolha uma opção [1-3]: "
  read -r option

  case $option in
    1) instalar ;;
    2) desinstalar ;;
    3) echo "Saindo..."; exit 0 ;;
    *) echo "Opção inválida." ;;
  esac
done
