# frozen_string_literal: true

# NOTE: ce controller est conservé uniquement pour compatibilité historique.
# Les routes /admin/logs pointent désormais vers Admin::SystemLogsController
# (cf. config/routes.rb). Vous pouvez supprimer ce fichier quand toutes les
# références legacy auront disparu.

module Admin
  class LogsController < Admin::BaseController
    def index
      redirect_to admin_system_logs_path
    end

    def show
      redirect_to admin_system_logs_path
    end
  end
end
