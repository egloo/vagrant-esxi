require "vagrant"

module VagrantPlugins
  module ESXi
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :host
      attr_accessor :user
      attr_accessor :password
      attr_accessor :name
      attr_accessor :datastore
      attr_accessor :vm_path
      attr_accessor :box_name
      attr_accessor :version
      attr_accessor :vm_format

      def validate(machine)
        errors = _detected_errors

        errors << I18n.t("config.host") if host.nil?
        errors << I18n.t("config.user") if user.nil?
        errors << I18n.t("config.password") if password.nil?
        errors << I18n.t("config.name") if name.nil?
        errors << I18n.t("config.datastore") if datastore.nil?
        errors << I18n.t("config.vm_path") if vm_path.nil?
        errors << I18n.t("config.box_name") if box_name.nil?
        errors << I18n.t("config.version") if version.nil?
        errors << I18n.t("config.vm_format") if vm_format.nil?

        { "esxi Provider" => errors }
      end
    end
  end
end
