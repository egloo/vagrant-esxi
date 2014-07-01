require "i18n"
require "open3"

module VagrantPlugins
  module ESXi
    module Action
      class Create

        def initialize(app, env)
          @app = app
        end

        def call(env)
          config = env[:machine].provider_config

          src = env[:machine].config.vm.box
          dst = config.name

          env[:ui].info(I18n.t("vagrant_esxi.copying"))
          # env[:ui].info("'/Applications/VMware Fusion.app/Contents/Library/VMware OVF Tool/ovftool' --diskMode=seSparse --name=#{dst} --net:'nat=VM Network 2' --noSSLVerify --overwrite #{config.vm_path}/#{src}/#{config.version}/#{config.vm_format}/#{config.box_name}.vmx vi://#{config.user}:#{config.password}@#{config.host}")
          system("'/Applications/VMware Fusion.app/Contents/Library/VMware OVF Tool/ovftool' --diskMode=seSparse --name=#{dst} --net:'nat=VM Network 2' --noSSLVerify --overwrite #{config.vm_path}/#{src}/#{config.version}/#{config.vm_format}/#{config.box_name}.vmx vi://#{config.user}:#{config.password}@#{config.host}") unless system("ssh #{config.user}@#{config.host} test -e /vmfs/volumes/#{config.datastore}/#{dst}")

          env[:ui].info(I18n.t("vagrant_esxi.creating"))
          # raise Error::ESXiError, :message => "#{dst} exists!" if system("ssh #{config.user}@#{config.host} test -e /vmfs/volumes/#{config.datastore}/#{dst}")

          # cmd = [
          #        "mkdir -p /vmfs/volumes/#{config.datastore}/#{dst}",
          #        "'find /vmfs/volumes/#{config.datastore}/#{src} -type f \\! -name \\*.iso -exec cp \\{\\} /vmfs/volumes/#{config.datastore}/#{dst}/ \\;'",
          #        "'cd /vmfs/volumes/#{config.datastore}/#{dst}'",
          #        "'find /vmfs/volumes/#{config.datastore}/#{src} -type f -name \\*.iso -exec ln -s \\{\\} \\;'",
          #        "mv /vmfs/volumes/#{config.datastore}/#{dst}/#{src}.vmx /vmfs/volumes/#{config.datastore}/#{dst}/#{src}.vmx.bak",
          #        "grep -v -e '^uuid.location' -e '^uuid.bios' -e '^vc.uuid' /vmfs/volumes/#{config.datastore}/#{dst}/#{src}.vmx.bak '>' /vmfs/volumes/#{config.datastore}/#{dst}/#{dst}.vmx",
          #        "rm /vmfs/volumes/#{config.datastore}/#{dst}/#{src}.vmx.bak",
          #        "chmod +x /vmfs/volumes/#{config.datastore}/#{dst}/#{dst}.vmx",
          #       ]
          # system("ssh #{config.user}@#{config.host} " + cmd.join(" '&&' "))

          env[:ui].info(I18n.t("vagrant_esxi.registering"))
          o, s = Open3.capture2("ssh #{config.user}@#{config.host} vim-cmd solo/registervm '/vmfs/volumes/#{config.datastore}/#{dst}/#{dst}.vmx'")

          # system("ssh #{config.user}@#{config.host} vim-cmd vmsvc/unregister '[#{config.datastore}]\\ #{src}/#{src}.vmx'")
          # system("ssh #{config.user}@#{config.host} rm -rf /vmfs/volumes/#{config.datastore}/#{src}")

          env[:machine].id = "#{config.host}:#{o.chomp}"

          @app.call env
        end
      end
    end
  end
end
